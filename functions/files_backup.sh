#!/bin/bash
# Function for site backup

backupFiles() {
    if [[ "$backup_files" != "true" ]] 
    then
        logEvent "$MSG_FILES_SKIP"
        return 0
    fi

    if [[ -r ${app_dir%%/}/backends/${files_backend}.sh ]]
    then :
    else
        logEvent "$MSG_NO_BACKEND"
        return 1
    fi

    runHook "${hooks_pre_files-}" || return 1

    logEvent "$MSG_FILES_START"

    for dir in ${files_dirs[@]}
    do
        archive_name="${dir//'/'/_}.${date_suffix}.tar.gz"
        source "${app_dir}/backends/${files_backend}.sh"

        GZIP=-9 tar -cz "$dir" 2> /dev/null | $stdin_conn

        if [[ ${PIPESTATUS[0]} != 0 || ${PIPESTATUS[1]} != 0 ]]
        then
            logEvent "$MSG_FILES_WARN ${PIPESTATUS[@]}"
        fi
    done

    logEvent "$MSG_FILES_FINISH"

    runHook "${hooks_post_files-}" || return 1
}
