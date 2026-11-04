import fs from 'node:fs'
import path from 'node:path'
import os from 'node:os'

// 1. Bun 글로벌 경로 탐색 (BUN_INSTALL -> scoop -> ~/.bun 순)
function findBunGlobalPkgJson() {
  const candidates = [
    process.env.BUN_INSTALL && path.join(process.env.BUN_INSTALL, 'install', 'global', 'package.json'),
    path.join(os.homedir(), 'scoop', 'persist', 'bun', 'install', 'global', 'package.json'),
    path.join(os.homedir(), '.bun', 'install', 'global', 'package.json'),
  ].filter(Boolean)

  for (const p of candidates) {
    if (fs.existsSync(p)) return p
  }
  return null
}

const pkgJsonPath = findBunGlobalPkgJson()
if (!pkgJsonPath) {
  console.error('Bun global package.json을 찾을 수 없습니다.')
  process.exit(1)
}

const globalNodeModules = path.join(path.dirname(pkgJsonPath), 'node_modules')

// 2. semver 라이브러리 동적 로드
let semver
try {
  semver = (await import('semver')).default
} catch {
  try {
    semver = (await import(path.join(globalNodeModules, 'semver'))).default
  } catch {
    console.log('`semver` 라이브러리가 없어 글로벌로 설치합니다...')
    Bun.spawnSync(['bun', 'add', '-g', 'semver'], {
      stdio: ['inherit', 'inherit', 'inherit']
    })
    semver = (await import(path.join(globalNodeModules, 'semver'))).default
  }
}

const pkg = JSON.parse(fs.readFileSync(pkgJsonPath, 'utf8'))
const deps = pkg.dependencies || {}

const targets = []
const skipped = []

// 3. 의도된 버전에 따른 타겟 결정
function resolveTarget(name, rawVer) {
  const ver = rawVer.trim()

  // 1) 기본 최신 / 와일드카드
  if (!ver || ver === '*' || ver === 'latest') {
    return { type: 'latest', target: `${name}@latest` }
  }

  // 2) dist-tag (next, canary, beta 등)
  if (!semver.validRange(ver) && !semver.valid(ver)) {
    return { type: 'tag', target: `${name}@${ver}` }
  }

  // 3) 완전 고정 버전 (예: "3.6.3", "=3.6.3", "v3.6.3")
  // ^나 ~가 없고 exact version으로 파싱되는 경우 -> 변경 없이 건너뜀
  const cleanVer = semver.clean(ver)
  if (cleanVer && !ver.startsWith('^') && !ver.startsWith('~')) {
    return { type: 'pinned', target: null, reason: `버전 고정됨 (${ver})` }
  }

  // 4) 사용자가 명시적으로 범위/마이너를 지정한 경우 (예: "2.0", "~1.2.0", "2.x")
  // 해당 범위 그대로 넘겨서 범위 내 최신을 받게 하고, package.json 표기도 유지
  const isExplicitRange =
    ver.startsWith('~') ||
    /^\d+\.\d+$/.test(ver) ||       // 예: "2.0"
    /^\d+$/.test(ver) ||             // 예: "2"
    ver.includes('.x') ||
    ver.includes('.*')

  if (isExplicitRange) {
    return { type: 'range', target: `${name}@${ver}` }
  }

  // 5) Bun이 bun add -g 시 자동으로 생성한 캐럿 버전 (예: "^2.1.268")
  // 최신 버전(@latest)으로 업데이트
  return { type: 'latest', target: `${name}@latest` }
}

for (const [name, rawVer] of Object.entries(deps)) {
  const res = resolveTarget(name, rawVer)
  if (res.target) {
    targets.push(res.target)
  } else {
    skipped.push(`${name} (${res.reason})`)
  }
}

if (skipped.length > 0) {
  console.log('📌 고정 버전으로 인해 건너뛰는 패키지:')
  for (const s of skipped) console.log(`  - ${s}`)
  console.log()
}

if (targets.length === 0) {
  console.log('업데이트할 대상 패키지가 없습니다.')
  process.exit(0)
}

console.log('🚀 다음 타겟으로 Bun global 패키지 업데이트를 진행합니다:')
for (const t of targets) console.log(`  - ${t}`)
console.log()

// 4. bun add -g 실행
const proc = Bun.spawnSync(['bun', 'add', '-g', ...targets], {
  stdio: ['inherit', 'inherit', 'inherit']
})

process.exit(proc.exitCode)
