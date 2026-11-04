function _cdhost_init
    function cdhost
        if test -n (echo $WSL_DISTRO_NAME)
            and test -n (which wslpath)
            and test -n (which wslvar)

            if string match -eq (echo ~) $argv[1]
                cd (wslpath -u (wslvar USERPROFILE))
                if test -n ./0
                    rm -f ./0
                end
            else if string length -q (wslvar $argv[1]) >0
                cd (wslpath -u (wslvar $argv[1]))
                if test -n ./0
                    rm -f ./0
                end

            else
                cd (wslpath -u $argv[1])
                if test -n ./0
                    rm -f ./0
                end
            end
        else
            echo "cdhost: This command is only available in WSL"
        end
    end
end
