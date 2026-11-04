function _lndir_init
    if test -f ~/.lndir
        for line in (cat ~/.lndir)
            # Ignore comments and empty lines
            if test -z "$line"
                continue
            end

            if string match -q "#*" -- "$line"
                continue
            end

            set line (echo $line | sed 's/#.*$//' | string trim)

            if test -z "$line"
                continue
            end

            set full_dest_path (echo $line | cut -d'|' -f1 | string trim)
            set base_full_path (echo $line | cut -d'|' -f2 | string trim)

            set base_dir (echo $base_full_path | awk -F/ '{print $NF}')
            set base_path (echo $base_full_path | sed "s|/$base_dir\$||")

            set dir (echo $full_dest_path | awk -F/ '{print $NF}')

            if string match -q -- "$base_full_path*" $PWD
                if test (echo $PWD) = "$base_full_path"
                    eval cd "$full_dest_path"
                else
                    eval cd "$full_dest_path$(echo $PWD | sed "s|$base_full_path||")"
                end
            end
        end
    end
end
