#!/bin/bash

# © Ncode. All rights reserved
# 
# WP manager - WordPress manager
# Written by Noam Alum
# Use at your own risk.
#
# Documentation at https://ncode.codes/assets/single_snippet/Single_codes.php?code=WPM
#
# Visit ncode.codes for more scripts like this :)
#

# WP MANAGER
    # CASE IN CTRL+C
        function cleanup() {
            echo ""
            rm -rf $0
            exit 1
        }
        trap cleanup INT
    # CASE IN CTRL+C

    # CHECK COMMANDS
        function check_COMMAND {
            if [ "$?" != "0" ]; then
                export ERROR_count=$(( ${ERROR_count} + 1 ))
            fi
        }
    # CHECK COMMANDS

    # DEFINE COLORS
        function ColoRs {
            local Var_Name="$1"
            local Color="$2"

            # Define colors
            declare -A color_list
            color_list[cyan]='\e[96m'
            color_list[red]='\e[91m'
            color_list[blue]='\e[94m'
            color_list[green]='\e[92m'
            color_list[yellow]='\e[93m'
            color_list[white]='\e[97m'
            color_list[black]='\e[30m'
            color_list[gray]='\e[90m'
            color_list[magenta]='\e[95m'
            color_list[orange]='\e[38;5;208m'
            color_list[purple]='\e[38;5;129m'

            # Default to white if the color is not found
            if [ -z "${color_list[$Color]}" ]; then
                Color='\e[97m'
            else
                Color="${color_list[$Color]}"
            fi

            local Text="$3"
            
            # Create a variable with the specified name and set its value with color formatting
            export "$Var_Name"="$Color$Text\e[0m"
        }
    # DEFINE COLORS

    # EXTERNAL MIGRATION
        function MigrateSiteExternal {
            # STOP SCRIPT
                if [ "$ISnoam" != "YES" ]; then
                    echo "Not ready yet :)"
                    exit 0
                fi
            # STOP SCRIPT

            # COLOR
                ColoRs Err_S red !!!
                ColoRs C_Error red ERROR
            # COLOR
            
            # GET USER INPUT AND CHECK
                function remoteLocation_F {
                    read -p "What is the host of the new location? : " RemoteHost
                    export RemoteHost

                    # COLOR
                        ColoRs C_remote red $RemoteHost
                        ColoRs C_SUCCESs green SUCCESS
                    # COLOR

                    if [ -z "$RemoteHost" ]; then
                        remoteLocation_F
                    elif [ "$(ping -c 1 -W 1 "$RemoteHost" >/dev/null 2>&1; echo $?)" != "0" ]; then
                        echo -e "|$C_Error| The host $C_remote is unreachable |$C_Error|"
                        remoteLocation_F
                    else
                        echo -e "Are you sure that $C_remote is the right host? "
                        GUSER_answer
                        if [ "$USER_answer" == "Y" ]; then
                            echo "OK."
                        else
                            remoteLocation_F
                        fi
                    fi
                }
                remoteLocation_F

                function remoteUser_F {
                    read -p "What is the user you want to use to access $RemoteHost? : " remoteUser
                    export remoteUser

                    # COLOR
                    ColoRs C_user red $remoteUser
                    # COLOR

                    if [ -z "$remoteUser" ]; then
                        remoteUser_F
                    else
                        echo -e "Are you sure that $C_user is the right user? "
                        GUSER_answer
                        if [ "$USER_answer" == "Y" ]; then
                            echo "OK."
                        else
                            remoteUser_F
                        fi
                    fi
                }

                remoteUser_F
                function SSH_port_F {
                    read -p "What is the port you want to use to access $RemoteHost through SSH? : " SSH_port
                    export SSH_port

                    # COLOR
                    ColoRs C_SSH_port red $SSH_port
                    # COLOR

                    if [ -z "$SSH_port" ]; then
                        SSH_port_F
                    else
                        echo -e "Are you sure that $C_SSH_port is the right port to access SSH? "
                        GUSER_answer
                        if [ "$USER_answer" == "Y" ]; then
                            echo "OK."
                        else
                            SSH_port_F
                        fi
                    fi
                }

                SSH_port_F

                function remotePath_F {
                    read -p "What is the path to the new directory in $RemoteHost? : " remotePath
                    export remotePath

                    # COLOR
                        ColoRs C_Rpath red $remotePath
                    # COLOR

                    if [ -z "$remotePath" ]; then
                        remotePath_F
                    else
                        echo -e "Are you sure that $C_Rpath is the right path? "
                        GUSER_answer
                        if [ "$USER_answer" == "Y" ]; then
                            echo "OK."
                            # CHECK REMOTE PATH && CONNECTION
                                RemotePathCheck=$(ssh -p $SSH_port -o ConnectTimeout=3 "$remoteUser@$RemoteHost" "if [ ! -e \"$remotePath\" ]; then echo \"NOT_EXIST\"; fi")
                                if [ "$?" != 0 ]; then
                                    echo -e "|$C_Error| COULD NOT CONNECT TO \"$C_remote\" AS \"$C_user\"! |$C_Error|"
                                    MigrateSiteExternal
                                elif [ "$RemotePathCheck" == "NOT_EXIST" ]; then
                                    echo -e "|$C_Error| COULD NOT FIND \"$C_Rpath\" IN \"$C_remote\"! |$C_Error|"
                                    remotePath_F
                                else
                                    echo -e "$C_SUCCESs, connected to $C_remote successfully."
                                fi
                            # CHECK REMOTE PATH && CONNECTION
                        else
                            remotePath_F
                        fi
                    fi
                }

                remotePath_F
            # GET USER INPUT AND CHECK

            # SHOW PREVIEW
                # VARS
                    NEW_owner=$remoteUser
                # VARS

                # COLOR
                    ColoRs C_SSH_port cyan $SSH_port
                    ColoRs C_tar_file green "$Tar_File"
                    ColoRs C_remoteUser cyan $remoteUser
                    ColoRs C_RemoteHost cyan $RemoteHost
                    ColoRs C_remotePath green $remotePath
                    ColoRs C_CurrentDir green $CurrentDir
                    ColoRs C_tar_opt cyan xzf
                    ColoRs C_remove_what orange "$Tar_File $CurrentDir"
                    ColoRs C_tar_file_R orange "$Tar_File"
                    ColoRs C_remove red 'rm -rf'
                    ColoRs C_newdir_Owner $NEW_owner
                # COLOR

                echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS ON REMOTE SERVER: $Err_S"
                echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                echo -e "# # LOCAL"
                echo -e "# rsync -avz -e "ssh -p $C_SSH_port" $C_tar_file $C_remoteUser@$C_RemoteHost:$C_remotePath <- move $C_tar_file to $C_remotePath in $C_RemoteHost\n#"
                echo -e "# # EXTERNAL"
                echo -e "# cd $C_remotePath <- go to the $C_remotePath directory in $C_RemoteHost\n#"
                echo -e "# tar $C_tar_opt $C_tar_file <- extract $C_tar_file\n#"
                echo -e "# mv $C_CurrentDir/* .; mv $C_CurrentDir/.htaccess . <- move all files from $C_tar_file to $C_remotePath\n#"
                echo -e "# $C_remove $C_remove_what <- $C_explane_REMOVE $C_tar_file and $C_remotePath\n#"
                echo -e "# chown -R $C_newdir_Owner.$C_newdir_Owner * .htaccess <- change the owner of the files to the new owner\#"
                echo -e "# # LOCAL"
                echo -e "# $C_remove $C_tar_file_R <- remove the tar.gz file from local server.\n#"
                echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                GUSER_answer
            # SHOW PREVIEW

            if [ "$USER_answer" == "Y" ]; then
                function RunRemoteCommands_F {
                    # RUN COMMANDS
                        export ERROR_count="0"
                        echo -e "Password for rsync command:"
                        rsync -avz -e "ssh -p $SSH_port" $Tar_File $remoteUser@$RemoteHost:$remotePath > /dev/null
                        check_COMMAND
                        if [ "$ERROR_count" != "0" ]; then
                            # COLOR
                                ColoRs C_Error red ERROR
                                ColoRs C_SUCCESs green SUCCESS
                            # COLOR

                            echo -e "|$C_Error| RSYNC FAILD! TRY SCP? |$C_Error|"
                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                scp -P $SSH_port $Tar_File $remoteUser@$RemoteHost:$remotePath
                            else
                                echo "OK. exiting."
                                exit 0
                            fi
                        fi

                        echo -e "\nPassword for the rest of the commands"
                        RemoteSshCommandsRes="$(ssh -p $SSH_port "$remoteUser@$RemoteHost" "
                            # IMPORT CHECK COMMANDS
                                function check_COMMAND {
                                    if [ \"\$?\" != \"0\" ]; then
                                        export ERROR_count=$(( ${ERROR_count} + 1 ))
                                    fi
                                }
                            # IMPORT CHECK COMMANDS

                            # RUN REMOTE COMMANDS
                                ERROR_count=\"0\"
                                cd $remotePath
                                check_COMMAND
                                tar xzf $Tar_File
                                check_COMMAND
                                chown -R $NEW_owner.$NEW_owner *
                                check_COMMAND
                                chown -R $NEW_owner.$NEW_owner .htaccess
                                mv $CurrentDir/* .
                                check_COMMAND
                                mv $CurrentDir/.htaccess .
                                check_COMMAND
                                rm -rf $CurrentDir $Tar_File $0
                                check_COMMAND
                                echo \"ERRORCOUNT \$ERROR_count\"
                            # RUN REMOTE COMMANDS
                        ")"
                        ERROR_count="$(echo "$RemoteSshCommandsRes" | grep "$ERRORCOUNT" | awk {'print $NF'})"
                    # RUN COMMANDS

                    # CHECK FOR ERRORS
                        if [ "$ERROR_count" == "0" ]; then
                            # COLOR
                                ColoRs C_SUCCESs green SUCCESS
                            # COLOR

                            echo -e "$C_SUCCESs!"
                            
                        # ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------> NOT CHECKED NEED TO CHECK

                            echo "To search and replace to $NEW_dom we need new database & database user."
                            GUSER_answer

                            if [ "$USER_answer" == "Y" ]; then
                                echo "Would you like to create them? "
                                GUSER_answer
                                if [ "$USER_answer" == "Y" ]; then
                                    # GET USER INPUT AND CHECK
                                        # CHECK MYSQL ROOT PASSWORD
                                            function get_MYSQL_root {
                                                read -p "Remote mysql root password : " Rdbrp
                                                while [ -z "$Rdbrp" ]
                                                do
                                                    get_MYSQL_root
                                                done

                                                MYSQLcheck=$(ssh -p $SSH_port -o ConnectTimeout=3 "$remoteUser@$RemoteHost" "mysql -u root -p\"$Rdbrp\" -e \"SHOW DATABASES;\" &> /dev/null;echo \$?")
                                                while [ $MYSQLcheck -ne 0 ]
                                                do
                                                    ColoRs C_Error red ERROR
                                                    echo -e "|$C_Error| \"$Rdbrp\" IS INCORRECT! |$C_Error|"
                                                    get_MYSQL_root
                                                done
                                            }
                                            get_MYSQL_root
                                        # CHECK MYSQL ROOT PASSWORD

                                        # CHECK DB
                                            function get_newDB {
                                                ColoRs C_notuse_q red "'"
                                                ColoRs C_Error red ERROR
                                                read -p "New database name : " new_database_name
                                                echo -e "Are you sure that $new_database_name is the name you want?"
                                                GUSER_answer
                                                while [ -z "$new_database_name" ]
                                                do
                                                    get_newDB
                                                done
                                                if [ "$USER_answer" == "Y" ]; then
                                                    echo "OK."
                                                        if [ ! -z "$(echo $new_database_name | grep "'" )" ]; then
                                                            echo -e "|$C_Error| THE DATABASE NAME \"$new_database_name\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                            get_newDB
                                                        fi
                                                else
                                                    get_newDB
                                                    while [ -z "$new_database_name" ]
                                                    do
                                                        get_newDB
                                                    done
                                                fi
                                            }

                                            function get_newDB_USER  {
                                                ColoRs C_notuse_q red "'"
                                                ColoRs C_Error red ERROR
                                                read -p "New database user name : " new_database_user
                                                echo -e "Are you sure that $new_database_user is the name you want?"
                                                GUSER_answer
                                                while [ -z "$new_database_user" ]
                                                do
                                                    get_newDB_USER
                                                done
                                                if [ "$USER_answer" == "Y" ]; then
                                                    echo "OK."
                                                    if [ ! -z "$(echo $new_database_user | grep "'" )" ]; then
                                                        echo -e "|$C_Error| THE USERNAME \"$new_database_user\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                        get_newDB_USER
                                                    fi
                                                else
                                                    get_newDB_USER
                                                    while [ -z "$new_database_user" ]
                                                    do
                                                        get_newDB_USER
                                                    done
                                                fi
                                            }
                                            function get_newDB_pass  {
                                                # COLOR
                                                    ColoRs C_new_database_password red $new_database_password
                                                    ColoRs C_Error red ERROR
                                                    ColoRs C_notuse_q red "'"
                                                # COLOR
                                                read -p "New database user password : " new_database_password
                                                echo -e "Are you sure that $new_database_password is the password you want?"
                                                GUSER_answer
                                                while [ -z "$new_database_password" ]
                                                do
                                                    get_newDB_pass
                                                done
                                                if [ "$USER_answer" == "Y" ]; then
                                                    echo "OK."
                                                    
                                                    if [ ! -z "$(echo $new_database_password | grep "'" )" ]; then
                                                        echo -e "|$C_Error| THE PASSWORD \"$new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                        get_newDB_pass
                                                    fi
                                                    
                                                    while [ -z "$new_database_password" ]
                                                    do
                                                        get_newDB_pass
                                                    done
                                                fi
                                            }
                                            get_newDB
                                            get_newDB_USER
                                            get_newDB_pass
                                        # CHECK DB
                                    # GET USER INPUT AND CHECK

                                    # COLORS
                                        ColoRs C_SUCCESs green SUCCESS
                                        ColoRs Err_S red !!!

                                        ColoRs C_db_p cyan $new_database_password
                                        ColoRs C_db_u cyan $new_database_user
                                        ColoRs C_db_d cyan $new_database_name
                                        ColoRs C_Rdbrp cyan $Rdbrp
                                    # COLORS

                                    # PEVIEW
                                        echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS ON REMOTE SERVER: $Err_S"
                                        echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -\n# REMOTE HOST:"
                                        echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"CREATE DATABASE $C_db_d;\" <- create the new database.\n#"
                                        echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"CREATE USER $C_db_u@localhost IDENTIFIED BY '$C_db_p';\" <- create the new user.\n#"
                                        echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"GRANT ALL PRIVILEGES ON $C_db_d.* TO $C_db_u@localhost IDENTIFIED BY '$C_db_p';\" <- give the new user all privileges.\n#"
                                        echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"FLUSH PRIVILEGES;\" <- flushing the newly assigned privileges.\n#"
                                        echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                    # PEVIEW
                                    GUSER_answer

                                    if [ "$USER_answer" == "Y" ]; then
                                        # RUN COMMANDS
                                            RemoteSshCommandsRes="$(ssh -p $SSH_port "$remoteUser@$RemoteHost" "
                                                # IMPORT CHECK COMMANDS
                                                    function check_COMMAND {
                                                        if [ \"\$?\" != \"0\" ]; then
                                                            export ERROR_count=$(( ${ERROR_count} + 1 ))
                                                        fi
                                                    }
                                                # IMPORT CHECK COMMANDS

                                                # RUN REMOTE COMMANDS
                                                    ERROR_count=\"0\"
                                                    mysql -u root -p\"$Rdbrp\" -e \"CREATE DATABASE $new_database_name;\"
                                                    check_COMMAND
                                                    mysql -u root -p\"$Rdbrp\" -e \"CREATE USER $new_database_user@localhost IDENTIFIED BY '$new_database_password';\"
                                                    check_COMMAND
                                                    mysql -u root -p\"$Rdbrp\" -e \"GRANT ALL PRIVILEGES ON $new_database_name.* TO $new_database_user@localhost IDENTIFIED BY '$new_database_password';\"
                                                    check_COMMAND
                                                    mysql -u root -p\"$Rdbrp\" -e \"FLUSH PRIVILEGES;\"
                                                    check_COMMAND
                                                    echo \"ERRORCOUNT \$ERROR_count\"
                                                # RUN REMOTE COMMANDS
                                            ")"
                                            ERROR_count="$(echo "$RemoteSshCommandsRes" | grep "$ERRORCOUNT" | awk {'print $NF'})"
                                        # RUN COMMANDS

                                        if [ "$ERROR_count" != 0]; then
                                            ColoRs C_Error red ERROR
                                            echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                            rm -rf $0
                                            exit 1
                                        fi
                                    else
                                        echo "OK."
                                        exit 0
                                    fi
                                else
                                    # GET USER INPUT AND CHECK
                                        ColoRs C_note red NOTE
                                        echo "|$C_note| ON THE REMOMTE SERVER |$C_note|"

                                        function new_db_name {
                                            read -p "database name : " new_database_name
                                            # COLOR
                                                ColoRs C_new_database_name red $new_database_name
                                                ColoRs C_notuse_q red "'"
                                                ColoRs C_Error red ERROR
                                            # COLOR

                                            if [ ! -z "$(echo $new_database_name | grep "'" )" ]; then
                                                echo -e "|$C_Error| THE DATABASE NAME \"$new_database_name\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                new_db_name
                                            fi

                                            while [ -z "$new_database_name" ]
                                            do
                                                new_db_name
                                            done
                                            echo -e "Are you sure $C_new_database_name is the database name you want?"
                                            GUSER_answer
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                            else
                                                new_db_name
                                            fi
                                        }

                                        function new_db_username {
                                            read -p "database user name : " new_database_user
                                            # COLOR
                                                ColoRs C_new_database_user red $new_database_user
                                                ColoRs C_notuse_q red "'"
                                                ColoRs C_Error red ERROR
                                            # COLOR

                                            if [ ! -z "$(echo $new_database_user | grep "'" )" ]; then
                                                echo -e "|$C_Error| THE USERNAME \"$new_database_user\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                new_db_username
                                            fi

                                            while [ -z "$new_database_user" ]
                                            do
                                                new_db_username
                                            done
                                            echo -e "Are you sure $C_new_database_user is the username you want?"
                                            GUSER_answer
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                            else
                                                new_db_username
                                            fi
                                        }

                                        function new_db_password {
                                            read -p "database user password : " new_database_password
                                            # COLOR
                                                ColoRs C_new_database_password red $new_database_password
                                                ColoRs C_Error red ERROR
                                                ColoRs C_notuse_q red "'"
                                            # COLOR

                                            if [ ! -z "$(echo $new_database_password | grep "'" )" ]; then
                                                echo -e "|$C_Error| THE PASSWORD \"$new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                new_db_password
                                            fi

                                            while [ -z "$new_database_password" ]
                                            do
                                                new_db_password
                                            done
                                            echo -e "Are you sure $C_new_database_password is the password you want?"
                                            GUSER_answer
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                                if [ ! -z "$(echo $new_database_password | grep -q "'" )" ]; then
                                                    echo -e "|$C_Error| THE PASSWORD \"$C_new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                    new_db_password
                                                fi
                                            else
                                                new_db_password
                                            fi
                                        }

                                        new_db_name
                                        new_db_username
                                        new_db_password

                                        MYSQLcheck=$(ssh -p $SSH_port -o ConnectTimeout=3 "$remoteUser@$RemoteHost" "mysql -u \"$new_database_user\" -p\"$new_database_password\" -e \"use $new_database_name\" &>/dev/null;echo \$?")
                                        while [ $MYSQLcheck -ne 0 ]
                                        do
                                            ColoRs C_Error red ERROR
                                            echo -e "|$C_Error| \"$new_database_user\" DOESNT HAVE THE RIGHT PRIVILAGES ON \"$new_database_name\" OR IT DOES NOT EXIST ! |$C_Error|"
                                            new_db_name
                                            new_db_username
                                            new_db_password
                                        done
                                    # GET USER INPUT AND CHECK
                                fi

                                # COLORS
                                    ColoRs C_SUCCESs green SUCCESS
                                    ColoRs Err_S red !!!
                                    ColoRs C_database_name orange $database_name
                                    ColoRs C_new_database_name yellow $new_database_name

                                    ColoRs C_database_username orange $user_name
                                    ColoRs C_new_database_username yellow $new_database_user

                                    ColoRs C_database_password orange $database_password
                                    ColoRs C_new_database_password yellow $new_database_password

                                    ColoRs C_db_p cyan $new_database_password
                                    ColoRs C_db_u cyan $new_database_user
                                    ColoRs C_db_d cyan $new_database_name
                                    ColoRs C_sql_name cyan $sql_NAME

                                    ColoRs C_OLD_dom orange $OLD_dom
                                    ColoRs C_NEW_dom yellow $NEW_dom

                                    ColoRs C_RM_location orange "$sql_NAME"
                                    ColoRs C_explane_REMOVE red REMOVE
                                # COLORS

                                # PREVIEW
                                    echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS ON REMOTE HOST: $Err_S"
                                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                    echo -e "# sed -i \"s/$C_database_name/$C_new_database_name/g\" wp-config.php <- change database name from $C_database_name to $C_new_database_name\n#"
                                    echo -e "# sed -i \"s/$C_database_username/$C_new_database_username/g\" wp-config.php <- change user name from $C_database_username to $C_new_database_username\n#"
                                    echo -e "# sed -i \"s/$C_database_password/$C_new_database_password/g\" wp-config.php <- change password from $C_database_password to $C_new_database_password\n#"
                                    echo -e "# mysql -p$C_db_p -u $C_db_u $C_db_d < $C_sql_name <- import $C_sql_name to $C_db_d.\n#"
                                    echo -e "# $C_remove_sql $C_sql_name <- remove the sql file.\n#s"
                                    echo -e "# $C_remove_sql $C_RM_location <- $C_explane_REMOVE $C_RM_location\n#"
                                    echo -e "# wp search-replace '//$C_OLD_dom' '//$C_NEW_dom' --allow-root --all-tables --recurse-objects <- search and replace from $C_OLD_dom to $C_NEW_dom"
                                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                # PREVIEW

                                GUSER_answer
                                if [ "$USER_answer" == "Y" ]; then
                                    # RUN COMMANDS
                                        RemoteSshCommandsRes="$(ssh -p $SSH_port "$remoteUser@$RemoteHost" "
                                            # IMPORT CHECK COMMANDS
                                                function check_COMMAND {
                                                    if [ \"\$?\" != \"0\" ]; then
                                                        export ERROR_count=$(( ${ERROR_count} + 1 ))
                                                    fi
                                                }
                                            # IMPORT CHECK COMMANDS

                                            # RUN REMOTE COMMANDS
                                                ERROR_count=\"0\"
                                                sed -i "s/$database_name/$new_database_name/g" wp-config.php
                                                check_COMMAND
                                                sed -i "s/$user_name/$new_database_user/g" wp-config.php
                                                check_COMMAND
                                                sed -i "s/$database_password/$new_database_password/g" wp-config.php
                                                check_COMMAND
                                                mysql -p$new_database_password -u $new_database_user $new_database_name < $sql_NAME
                                                check_COMMAND
                                                rm -rf $sql_NAME
                                                wp search-replace "//$OLD_dom" "//$NEW_dom" --allow-root --all-tables --recurse-objects
                                                check_COMMAND
                                                rm -rf $0
                                                check_COMMAND
                                                echo \"ERRORCOUNT \$ERROR_count\"
                                            # RUN REMOTE COMMANDS
                                        ")"
                                        ERROR_count="$(echo "$RemoteSshCommandsRes" | grep "$ERRORCOUNT" | awk {'print $NF'})"
                                    # RUN COMMANDS

                                    if [ "$ERROR_count" != 0]; then
                                        ColoRs C_Error red ERROR
                                        echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                        rm -rf $0
                                        exit 1
                                    fi

                                    # CHECK FOR ELEMENTOR
                                    if [ wp plugin is-active elementor --allow-root ]; then
                                        # PREVIEW
                                            echo "Elementor detected."
                                            echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDSON REMOTE HOST: $Err_S"
                                            echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                            echo -e "# wp elementor replace-urls https://$C_OLD_dom https://$C_NEW_dom --force --allow-root <- search and replace from $C_OLD_dom to $C_NEW_dom\n#"
                                            echo -e "# wp elementor replace-urls https://www.$C_OLD_dom https://www.$C_NEW_dom --force --allow-root <- search and replace from www.$C_OLD_dom to www.$C_NEW_dom\n#"
                                            echo -e "# wp elementor flush-css --allow-root <- flush elementors cache.\n#"
                                            echo -e "# wp elementor library sync --force --allow-root <- sync elementors library\n#"
                                            echo -e "# wp elementor sync_library --force --allow-root <- sync elementors library\n#"
                                            echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                        # PREVIEW
                                        GUSER_answer
                                        if [ "$USER_answer" == "Y" ]; then
                                            # RUN COMMANDS
                                                RemoteSshCommandsRes="$(ssh -p $SSH_port "$remoteUser@$RemoteHost" "
                                                    # IMPORT CHECK COMMANDS
                                                        function check_COMMAND {
                                                            if [ \"\$?\" != \"0\" ]; then
                                                                export ERROR_count=$(( ${ERROR_count} + 1 ))
                                                            fi
                                                        }
                                                    # IMPORT CHECK COMMANDS

                                                    # RUN REMOTE COMMANDS
                                                        ERROR_count=\"0\"
                                                        wp elementor replace-urls https://$OLD_dom https://$NEW_dom --force --allow-root
                                                        check_COMMAND
                                                        wp elementor replace-urls https://www.$OLD_dom https://www.$NEW_dom --force --allow-root
                                                        check_COMMAND
                                                        wp elementor flush-css --allow-root
                                                        check_COMMAND
                                                        wp elementor library sync --force --allow-root
                                                        check_COMMAND
                                                        wp elementor sync_library --force --allow-root
                                                        check_COMMAND
                                                        echo \"ERRORCOUNT \$ERROR_count\"
                                                    # RUN REMOTE COMMANDS
                                                ")"
                                                ERROR_count="$(echo "$RemoteSshCommandsRes" | grep "$ERRORCOUNT" | awk {'print $NF'})"
                                            # RUN COMMANDS

                                            if [ "$ERROR_count" != 0]; then
                                                ColoRs C_Error red ERROR
                                                echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                                rm -rf $0
                                                exit 1
                                            fi

                                        else
                                            echo "OK."
                                            exit 0
                                        fi
                                    fi

                                    if [ "$ERROR_count" -eq 0 ]; then

                                        # SEARCH FOR OLD DOMIAN AND SEARCH FOR OLD PATH
                                        FindOldDOP="$(ssh -p $SSH_port "$remoteUser@$RemoteHost" "grep -rl \"$OLD_dom\"; grep -rl \"$CurrentDirPath\"")"
                                        if [ ! -z "$FindOldDOP" ]; then
                                            # COLOR
                                                ColoRs C_note red NOTE
                                            # COLOR

                                            echo -e "|$C_note| FOUND THE OLD DOMAIN $C_OLD_dom OR OLD PATH IN FILES! |$C_note|"
                                            echo -e "$FindOldDOP"
                                        fi

                                        echo -e "\n$C_SUCCESs, $C_OLD_dom has been changed to $C_NEW_dom"
                                        exit 0
                                    else
                                        ColoRs C_Error red ERROR
                                        echo -e "|$C_Error| got an error while running commands. |$C_Error|"
                                        exit 1
                                    fi
                                else
                                    echo "OK."
                                fi    
                            else
                                echo "OK."
                                exit 0
                            fi
                            
                        # ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------> NOT CHECKED NEED TO CHECK
 
                        else
                            ColoRs C_Error red ERROR
                            echo -e "|$C_Error| got an error while running commands. Try again. (CTRL+C to exit) |$C_Error|"
                            RunRemoteCommands_F
                        fi
                    # CHECK FOR ERRORS
                }
                RunRemoteCommands_F

            else
                echo "OK."
                exit 0
            fi
        }
    # EXTERNAL MIGRATION

    # LOCAL MIGRATION
        function MigrateSite {
            echo "Migrate site?"
            GUSER_answer
            # COLOR
                ColoRs C_note red NOTE
                ColoRs C_discl cyan 'This part of the script is less stable, it is your responsibility and I advise you do this on your own'
            # COLOR

            if [ "$USER_answer" == "Y" ]; then
                echo -e "|$C_note| $C_discl |$C_note|"
                read -p "Press enter to continue. (CTRL+C to exit)"

                # CHECK IF LOCAL OR EXTERNAL
                    read -p "Is this a local or external migrtion? [LOCAL/EXTERNAL] : " M_type

                    while [ -z "$M_type" ]; do
                            read -p "Is this a local or external migrtion? [LOCAL/EXTERNAL] : " M_type
                    done

                    while [ "$M_type" != "EXTERNAL" ] && [ "$M_type" != "LOCAL" ]; do
                                read -p "Is this a local or external migrtion? [LOCAL/EXTERNAL] : " M_type
                    done
                    if [ "$M_type" == "EXTERNAL" ]; then
                        echo "OK."
                        MigrateSiteExternal
                        exit 0
                    else
                        echo "OK."
                    fi
                # CHECK IF LOCAL OR EXTERNALL
                # GET USER INPUT AND CHECK
                    # GET NEW LOCATION
                        function new_locaton_f {
                            read -p "Where is your new location? (THIS IS THE ROOT DIRECTORY OF THE WEBSITE!) : " NEW_location

                            # COLOR
                                ColoRs C_NEW_location red $NEW_location
                                ColoRs C_TXT_NEW_location red 'new location'
                            # COLOR

                            echo -e "Are you sure that $C_NEW_location is your $C_TXT_NEW_location?"
                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                echo "OK."
                            else
                                new_locaton_f
                                while [ -z "$NEW_location" ]
                                do
                                    new_locaton_f
                                done
                                while [ ! -e "$NEW_location" ]
                                do
                                    ColoRs C_Error red ERROR
                                    echo -e "|$C_Error| \"$NEW_location\" WAS NOT FOUND! |$C_Error|"
                                    new_locaton_f
                                done
                            fi
                            while [ -z "$NEW_location" ]
                            do
                                new_locaton_f
                            done
                            while [ ! -e "$NEW_location" ]
                            do
                                ColoRs C_Error red ERROR
                                echo -e "|$C_Error| \"$NEW_location\" WAS NOT FOUND! |$C_Error|"
                                new_locaton_f
                            done
                        }
                        new_locaton_f
                    # GET NEW LOCATION

                    # COLOR
                        ColoRs C_old_domain red $OLD_dom
                        ColoRs C_TXT_old_domain red 'old domain'
                        ColoRs C_new_domain red $NEW_dom
                        ColoRs C_TXT_new_domain red 'new domain'
                    # COLOR

                    # GET OLD DONAIN
                        function old_domain_f {
                            read -p "What is your domain as of now? : " OLD_dom
                            while [ -z "$OLD_dom" ]
                            do
                                read -p "What is your domain as of now? : " OLD_dom
                            done
                            # COLOR
                                ColoRs C_old_domain red $OLD_dom
                                ColoRs C_TXT_old_domain red 'old domain'
                                ColoRs C_new_domain red $NEW_dom
                                ColoRs C_TXT_new_domain red 'new domain'
                            # COLOR
                            echo -e "Are you sure that $C_old_domain is your $C_TXT_old_domain?"
                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                echo "OK."
                            else
                                old_domain_f
                            fi
                        }
                        old_domain_f
                    # GET OLD DONAIN

                    # GET NEW DONAIN
                        function new_domain_f {
                            read -p "What is the new domain name? : " NEW_dom
                            while [ -z "$NEW_dom" ]
                            do
                                read -p "What is the new domain name? : " NEW_dom
                            done
                            # COLOR
                                ColoRs C_old_domain red $OLD_dom
                                ColoRs C_TXT_old_domain red 'old domain'
                                ColoRs C_new_domain red $NEW_dom
                                ColoRs C_TXT_new_domain red 'new domain'
                            # COLOR
                            echo -e "Are you sure that $C_new_domain is your $C_TXT_new_domain?"
                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                echo "OK."
                            else
                                new_domain_f
                            fi
                        }
                        new_domain_f
                    # GET NEW DONAIN
                # GET USER INPUT AND CHECK

                # GET NEW OWNER BASED ON PROVIDED DIR
                NEW_owner=$(stat -c "%U" $NEW_location)

                # COLOR
                    ColoRs Err_S red !!!
                    ColoRs C_new_location green "$NEW_location"
                    ColoRs C_tar_opt cyan xzf
                    ColoRs C_tar_file green "$Tar_File"
                    ColoRs C_remove_what orange "$C_tar_file $C_CurrentDir"
                    ColoRs C_newdir_Owner cyan $NEW_owner
                # COLOR

                # SHOW PREVIEW
                    echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS: $Err_S"
                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                    echo -e "# mv $C_tar_file $C_new_location <- move $C_tar_file to $C_new_location\n#"
                    echo -e "# cd $C_new_location <- go to the $C_new_location directory\n#"
                    echo -e "# tar $C_tar_opt $C_tar_file <- extract $C_tar_file\n#"
                    echo -e "# mv $C_CurrentDir/* .; mv $C_CurrentDir/.htaccess . <- move all files from $C_tar_file to $C_new_location\n#"
                    echo -e "# $C_remove_sql $C_remove_what <- $C_explane_REMOVE $C_tar_file and $C_CurrentDir\n#"
                    echo -e "# chown -R $C_newdir_Owner.$C_newdir_Owner * .htaccess <- change the owner of the files to the new owner\#"
                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                # SHOW PREVIEW

                GUSER_answer
                if [ "$USER_answer" == "Y" ]; then
                    # RUN COMMANDS
                        ERROR_count="0"
                        mv "$Tar_File" "$NEW_location"
                        check_COMMAND
                        cd "$NEW_location"
                        check_COMMAND
                        tar xzf "$Tar_File"
                        check_COMMAND
                        mv "$CurrentDir"/* .; mv "$CurrentDir/.htaccess" .
                        check_COMMAND
                        rm -rf "$Tar_File" "$CurrentDir"
                        check_COMMAND
                        chown -R $NEW_owner.$NEW_owner * .htaccess
                        check_COMMAND
                     # RUN COMMANDS
                    if [ "$ERROR_count" == "0" ]; then

                        ColoRs C_SUCCESs green SUCCESS
                        ColoRs C_tar_file cyan "$Tar_File"

                        echo -e "$C_SUCCESs!"
                        echo "To search and replace to $NEW_dom we need new database & database user."
                        GUSER_answer

                        if [ "$USER_answer" == "Y" ]; then
                            echo "Would you like to create them? "
                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                # GET USER INPUT AND CHECK
                                    # CHECK MYSQL ROOT PASSWORD
                                        function get_MYSQL_root {
                                            read -p "Mysql root password : " Rdbrp
                                            while [ -z "$Rdbrp" ]
                                            do
                                                get_MYSQL_root
                                            done

                                            mysql -u root -p"$Rdbrp" -e "SHOW DATABASES;" &> /dev/null
                                            while [ $? -ne 0 ]
                                            do
                                                ColoRs C_Error red ERROR
                                                echo -e "|$C_Error| \"$Rdbrp\" IS INCORRECT! |$C_Error|"
                                                get_MYSQL_root
                                            done
                                        }
                                        get_MYSQL_root
                                    # CHECK MYSQL ROOT PASSWORD

                                    # CHECK DB
                                        function get_newDB {
                                            ColoRs C_notuse_q red "'"
                                            ColoRs C_Error red ERROR
                                            read -p "New database name : " new_database_name
                                            echo -e "Are you sure that $new_database_name is the name you want?"
                                            GUSER_answer
                                            while [ -z "$new_database_name" ]
                                            do
                                                get_newDB
                                            done
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                                    if [ ! -z "$(echo $new_database_name | grep "'" )" ]; then
                                                        echo -e "|$C_Error| THE DATABASE NAME \"$new_database_name\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                        get_newDB
                                                    fi
                                            else
                                                get_newDB
                                                while [ -z "$new_database_name" ]
                                                do
                                                    get_newDB
                                                done
                                            fi
                                        }

                                        function get_newDB_USER  {
                                            ColoRs C_notuse_q red "'"
                                            ColoRs C_Error red ERROR
                                            read -p "New database user name : " new_database_user
                                            echo -e "Are you sure that $new_database_user is the name you want?"
                                            GUSER_answer
                                            while [ -z "$new_database_user" ]
                                            do
                                                get_newDB_USER
                                            done
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                                if [ ! -z "$(echo $new_database_user | grep "'" )" ]; then
                                                    echo -e "|$C_Error| THE USERNAME \"$new_database_user\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                    get_newDB_USER
                                                fi
                                            else
                                                get_newDB_USER
                                                while [ -z "$new_database_user" ]
                                                do
                                                    get_newDB_USER
                                                done
                                            fi
                                        }
                                        function get_newDB_pass  {
                                            # COLOR
                                                ColoRs C_new_database_password red $new_database_password
                                                ColoRs C_Error red ERROR
                                                ColoRs C_notuse_q red "'"
                                            # COLOR
                                            read -p "New database user password : " new_database_password
                                            echo -e "Are you sure that $new_database_password is the password you want?"
                                            GUSER_answer
                                            while [ -z "$new_database_password" ]
                                            do
                                                get_newDB_pass
                                            done
                                            if [ "$USER_answer" == "Y" ]; then
                                                echo "OK."
                                                
                                                if [ ! -z "$(echo $new_database_password | grep "'" )" ]; then
                                                    echo -e "|$C_Error| THE PASSWORD \"$new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                    get_newDB_pass
                                                fi
                                                
                                                while [ -z "$new_database_password" ]
                                                do
                                                    get_newDB_pass
                                                done
                                            fi
                                        }
                                        get_newDB
                                        get_newDB_USER
                                        get_newDB_pass
                                    # CHECK DB
                                # GET USER INPUT AND CHECK

                                # COLORS
                                    ColoRs C_SUCCESs green SUCCESS
                                    ColoRs Err_S red !!!

                                    ColoRs C_db_p cyan $new_database_password
                                    ColoRs C_db_u cyan $new_database_user
                                    ColoRs C_db_d cyan $new_database_name
                                    ColoRs C_Rdbrp cyan $Rdbrp
                                # COLORS

                                # PEVIEW
                                    echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS: $Err_S"
                                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                    echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"CREATE DATABASE $C_db_d;\" <- create the new database.\n#"
                                    echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"CREATE USER $C_db_u@localhost IDENTIFIED BY '$C_db_p';\" <- create the new user.\n#"
                                    echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"GRANT ALL PRIVILEGES ON $C_db_d.* TO $C_db_u@localhost IDENTIFIED BY '$C_db_p';\" <- give the new user all privileges.\n#"
                                    echo -e "# mysql -u root -p\"$C_Rdbrp\" -e \"FLUSH PRIVILEGES;\" <- flushing the newly assigned privileges.\n#"
                                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                # PEVIEW
                                GUSER_answer

                                if [ "$USER_answer" == "Y" ]; then
                                    # RUN COMMANDS
                                        ERROR_count="0"
                                        mysql -u root -p"$Rdbrp" -e "CREATE DATABASE $new_database_name;"
                                        check_COMMAND
                                        mysql -u root -p"$Rdbrp" -e "CREATE USER $new_database_user@localhost IDENTIFIED BY '$new_database_password';"
                                        check_COMMAND
                                        mysql -u root -p"$Rdbrp" -e "GRANT ALL PRIVILEGES ON $new_database_name.* TO $new_database_user@localhost IDENTIFIED BY '$new_database_password';"
                                        check_COMMAND
                                        mysql -u root -p"$Rdbrp" -e "FLUSH PRIVILEGES;"
                                        check_COMMAND
                                    # RUN COMMANDS

                                    if [ "$ERROR_count" != 0]; then
                                        ColoRs C_Error red ERROR
                                        echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                        rm -rf $0
                                        exit 1
                                    fi
                                else
                                    echo "OK."
                                    exit 0
                                fi
                            else
                                # GET USER INPUT AND CHECK
                                    function new_db_name {
                                        read -p "database name : " new_database_name
                                        # COLOR
                                            ColoRs C_new_database_name red $new_database_name
                                            ColoRs C_notuse_q red "'"
                                            ColoRs C_Error red ERROR
                                        # COLOR

                                        if [ ! -z "$(echo $new_database_name | grep "'" )" ]; then
                                            echo -e "|$C_Error| THE DATABASE NAME \"$new_database_name\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                            new_db_name
                                        fi

                                        while [ -z "$new_database_name" ]
                                        do
                                            new_db_name
                                        done
                                        echo -e "Are you sure $C_new_database_name is the database name you want?"
                                        GUSER_answer
                                        if [ "$USER_answer" == "Y" ]; then
                                            echo "OK."
                                        else
                                            new_db_name
                                        fi
                                    }

                                    function new_db_username {
                                        read -p "database user name : " new_database_user
                                        # COLOR
                                            ColoRs C_new_database_user red $new_database_user
                                            ColoRs C_notuse_q red "'"
                                            ColoRs C_Error red ERROR
                                        # COLOR

                                        if [ ! -z "$(echo $new_database_user | grep "'" )" ]; then
                                            echo -e "|$C_Error| THE USERNAME \"$new_database_user\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                            new_db_username
                                        fi

                                        while [ -z "$new_database_user" ]
                                        do
                                            new_db_username
                                        done
                                        echo -e "Are you sure $C_new_database_user is the username you want?"
                                        GUSER_answer
                                        if [ "$USER_answer" == "Y" ]; then
                                            echo "OK."
                                        else
                                            new_db_username
                                        fi
                                    }

                                    function new_db_password {
                                        read -p "database user password : " new_database_password
                                        # COLOR
                                            ColoRs C_new_database_password red $new_database_password
                                            ColoRs C_Error red ERROR
                                            ColoRs C_notuse_q red "'"
                                        # COLOR

                                        if [ ! -z "$(echo $new_database_password | grep "'" )" ]; then
                                            echo -e "|$C_Error| THE PASSWORD \"$new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                            new_db_password
                                        fi

                                        while [ -z "$new_database_password" ]
                                        do
                                            new_db_password
                                        done
                                        echo -e "Are you sure $C_new_database_password is the password you want?"
                                        GUSER_answer
                                        if [ "$USER_answer" == "Y" ]; then
                                            echo "OK."
                                            if [ ! -z "$(echo $new_database_password | grep -q "'" )" ]; then
                                                echo -e "|$C_Error| THE PASSWORD \"$C_new_database_password\" HAS A $C_notuse_q IN IT! |$C_Error|"
                                                new_db_password
                                            fi
                                        else
                                            new_db_password
                                        fi
                                    }

                                    new_db_name
                                    new_db_username
                                    new_db_password

                                    mysql -u "$new_database_user" -p"$new_database_password" -e "use $new_database_name" &>/dev/null
                                    while [ $? -ne 0 ]
                                    do
                                        ColoRs C_Error red ERROR
                                        echo -e "|$C_Error| \"$new_database_user\" DOESNT HAVE THE RIGHT PRIVILAGES ON \"$new_database_name\" OR IT DOES NOT EXIST ! |$C_Error|"
                                        new_db_name
                                        new_db_username
                                        new_db_password
                                    done
                                # GET USER INPUT AND CHECK
                            fi

                            # COLORS
                                ColoRs C_SUCCESs green SUCCESS
                                ColoRs Err_S red !!!
                                ColoRs C_database_name orange $database_name
                                ColoRs C_new_database_name yellow $new_database_name

                                ColoRs C_database_username orange $user_name
                                ColoRs C_new_database_username yellow $new_database_user

                                ColoRs C_database_password orange $database_password
                                ColoRs C_new_database_password yellow $new_database_password

                                ColoRs C_db_p cyan $new_database_password
                                ColoRs C_db_u cyan $new_database_user
                                ColoRs C_db_d cyan $new_database_name
                                ColoRs C_sql_name cyan $sql_NAME

                                ColoRs C_OLD_dom orange $OLD_dom
                                ColoRs C_NEW_dom yellow $NEW_dom

                                ColoRs C_RM_location orange "$sql_NAME"
                                ColoRs C_explane_REMOVE red REMOVE
                            # COLORS

                            # PREVIEW
                                echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS: $Err_S"
                                echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                echo -e "# sed -i \"s/$C_database_name/$C_new_database_name/g\" wp-config.php <- change database name from $C_database_name to $C_new_database_name\n#"
                                echo -e "# sed -i \"s/$C_database_username/$C_new_database_username/g\" wp-config.php <- change user name from $C_database_username to $C_new_database_username\n#"
                                echo -e "# sed -i \"s/$C_database_password/$C_new_database_password/g\" wp-config.php <- change password from $C_database_password to $C_new_database_password\n#"
                                echo -e "# mysql -p$C_db_p -u $C_db_u $C_db_d < $C_sql_name <- import $C_sql_name to $C_db_d.\n#"
                                echo -e "# $C_remove_sql $C_RM_location <- $C_explane_REMOVE $C_RM_location\n#"
                                echo -e "# wp search-replace '//$C_OLD_dom' '//$C_NEW_dom' --allow-root --all-tables --recurse-objects <- search and replace from $C_OLD_dom to $C_NEW_dom"
                                echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                            # PREVIEW

                            GUSER_answer
                            if [ "$USER_answer" == "Y" ]; then
                                # RUN COMMANDS
                                    sed -i "s/$database_name/$new_database_name/g" wp-config.php
                                    check_COMMAND
                                    sed -i "s/$user_name/$new_database_user/g" wp-config.php
                                    check_COMMAND
                                    sed -i "s/$database_password/$new_database_password/g" wp-config.php
                                    check_COMMAND
                                    mysql -p$new_database_password -u $new_database_user $new_database_name < $sql_NAME
                                    check_COMMAND
                                    wp search-replace "//$OLD_dom" "//$NEW_dom" --allow-root --all-tables --recurse-objects
                                    check_COMMAND
                                    rm -rf $0
                                    check_COMMAND
                                # RUN COMMANDS

                                if [ "$ERROR_count" != 0]; then
                                    ColoRs C_Error red ERROR
                                    echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                    rm -rf $0
                                    exit 1
                                fi

                                # CHECK FOR ELEMENTOR
                                if [ wp plugin is-active elementor --allow-root ]; then
                                    # PREVIEW
                                        echo "Elementor detected."
                                        echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS: $Err_S"
                                        echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                        echo -e "# wp elementor replace-urls https://$C_OLD_dom https://$C_NEW_dom --force --allow-root <- search and replace from $C_OLD_dom to $C_NEW_dom\n#"
                                        echo -e "# wp elementor replace-urls https://www.$C_OLD_dom https://www.$C_NEW_dom --force --allow-root <- search and replace from www.$C_OLD_dom to www.$C_NEW_dom\n#"
                                        echo -e "# wp elementor flush-css --allow-root <- flush elementors cache.\n#"
                                        echo -e "# wp elementor library sync --force --allow-root <- sync elementors library\n#"
                                        echo -e "# wp elementor sync_library --force --allow-root <- sync elementors library\n#"
                                        echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                                    # PREVIEW
                                    GUSER_answer
                                    if [ "$USER_answer" == "Y" ]; then
                                        # RUN COMMANDS
                                            ERROR_count="0"
                                            wp elementor replace-urls https://$OLD_dom https://$NEW_dom --force --allow-root
                                            check_COMMAND
                                            wp elementor replace-urls https://www.$OLD_dom https://www.$NEW_dom --force --allow-root
                                            check_COMMAND
                                            wp elementor flush-css --allow-root
                                            check_COMMAND
                                            wp elementor library sync --force --allow-root
                                            check_COMMAND
                                            wp elementor sync_library --force --allow-root
                                            check_COMMAND
                                        # RUN COMMANDS

                                        if [ "$ERROR_count" != 0]; then
                                            ColoRs C_Error red ERROR
                                            echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                                            rm -rf $0
                                            exit 1
                                        fi

                                    else
                                        echo "OK."
                                        exit 0
                                    fi
                                fi

                                if [ "$ERROR_count" -eq 0 ]; then

                                    # SEARCH FOR OLD DOMIAN
                                    grep -rl "$OLD_dom" &> /dev/null
                                    if [ $? -eq 0 ]; then
                                        # COLOR
                                            ColoRs C_note red NOTE
                                        # COLOR

                                        echo -e "|$C_note| FOUND THE OLD DOMAIN $C_OLD_dom IN FILES! |$C_note|"
                                        grep -rl "$OLD_dom"
                                    fi

                                    # SEARCH FOR OLD PATH
                                    grep -rl "$CurrentDirPath" &> /dev/null
                                    if [ $? -eq 0 ]; then
                                        # COLOR
                                            ColoRs C_note red NOTE
                                        # COLOR

                                        echo -e "|$C_note| FOUND THE OLD PATH $C_OLD_dom IN FILES! |$C_note|"
                                        grep -rl "$CurrentDirPath"
                                    fi

                                    echo -e "\n$C_SUCCESs, $C_OLD_dom has been changed to $C_NEW_dom"
                                    rm -rf $sql_NAME
                                    exit 0
                                else
                                    ColoRs C_Error red ERROR
                                    echo -e "|$C_Error| got an error while running commands. |$C_Error|"
                                    exit 1
                                fi
                            else
                                echo "OK."
                            fi    
                        else
                            echo "OK."
                            exit 0
                        fi
                    else
                        ColoRs C_Error red ERROR
                        echo -e "|$C_Error| got an error while running commands. EXITING |$C_Error|"
                        rm -rf $0
                        exit 1
                    fi
                else
                    echo "OK."
                    exit 0
                fi
            else
                echo "OK."
                exit 0
            fi
        }
    # LOCAL MIGRATION

    # COMPRESS DIRECTORY
        function Compress_DIR {
            # Compress directory?
            echo "Compress directory?"
            GUSER_answer
            if [ "$USER_answer" == "Y" ]; then

                # VARS
                    CurrentDir="$(basename $(pwd))"
                    CurrentDirPath="$(pwd)"
                    Tar_File="$(openssl rand -base64 $((20*3/4)) | tr -d '[:space:][:punct:]').tar.gz"
                # VARS

                # COLOR
                    ColoRs C_cd_loc cyan ..
                    ColoRs Err_S red !!!
                    ColoRs C_tar_opt cyan czf
                    ColoRs C_CurrentDir green $CurrentDir
                    ColoRs C_tar_file green $Tar_File
                    ColoRs C_remove_sql red 'rm -rf'
                    ColoRs C_RM_location orange "$CurrentDir/$sql_NAME"
                    ColoRs C_explane_REMOVE red REMOVE
                # COLOR

                # PREVIEW
                    echo -e "$Err_S ABOUT TO RUN THE FOLLOWING COMMANDS: $Err_S"
                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -\n#"
                    echo -e "# cd $C_cd_loc <- go one directory backwards\n#"
                    echo -e "# tar $C_tar_opt $C_tar_file $C_CurrentDir <- compress $C_CurrentDir to $C_tar_file\n#"
                    echo -e "# $C_remove_sql $C_RM_location <- $C_explane_REMOVE $C_RM_location\n#"
                    echo -e "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
                # PREVIEW

                GUSER_answer
                if [ "$USER_answer" == "Y" ]; then

                    # COLOR
                        ColoRs C_Stay_NOTIC purple 'This can take a while... Please dont exit.'
                    # COLOR

                    # RUN COMMANDS
                        ERROR_count="0"
                        echo -e "$C_Stay_NOTIC\n "
                        cd .. > /dev/null
                        check_COMMAND
                        tar czf $Tar_File $CurrentDir > /dev/null
                        check_COMMAND
                        rm -rf $CurrentDir/$sql_NAME > /dev/null
                        check_COMMAND
                    # RUN COMMANDS

                    if [ "$ERROR_count" == "0" ]; then
                        ColoRs C_SUCCESs green SUCCESS
                        ColoRs C_tar_file cyan $Tar_File
                        echo -e "$C_SUCCESs, file: $C_tar_file"
                        MigrateSite
                    else
                        ColoRs C_Error red ERROR
                        echo -e "|$C_Error| got an error while running commands. |$C_Error|"
                        exit 1
                    fi
                elif [ "$USER_answer" == "Y" ]; then
                    echo "OK."
                else
                    exit 0
                fi	
            fi
        }
    # COMPRESS DIRECTORY

    # GET INFO ABOUT DATABASE
        function get_info_DB {
            local Var="$1"
            local var_value=$(grep $Var wp-config.php | awk -F ", '" {'print $2'} | awk -F "'" {'print $1'})
            export "$2=$var_value"
        }
    # GET INFO ABOUT DATABASE

    # EXPORT DATABASE
        function Export_SQL {
                ERROR_count="0"
                mysqldump -u $user_name -p"$database_password" $database_name > "$sql_NAME"
                check_COMMAND
                if [ "$ERROR_count" == "0" ]; then
                    echo -e "Done, sql file: $C_sql_name"
                    Compress_DIR
                else
                    # COLOR
                        ColoRs C_ROot cyan 'ROOT?'
                        ColoRs C_Error red ERROR
                    # COLOR
        
                    echo -e "|$C_Error| can't run the command because of an error. try $C_ROot |$C_Error|"
                    GUSER_answer
                    if [ "$USER_answer" == "Y" ]; then
                        ERROR_count="0"
                        mysqldump $database_name > $sql_NAME
                        check_COMMAND
                        if [ "$ERROR_count" == "0" ]; then
                            echo -e "Done, sql file: C_sql_name"
                            Compress_DIR
                        else
                            ColoRs C_Error red ERROR
                            echo -e "|$C_Error| can't run the command. EXITING |$C_Error|"
                            rm -rf $sql_NAME
                            exit 1
                        fi
                    elif [ "$USER_answer" == "N" ]; then
                        echo "OK."
                        exit 0
                        rm -rf $sql_NAME
                    else
                        rm -rf $sql_NAME
                        exit 1
                    fi
                fi
        }
    # EXPORT DATABASE

    # GET USER INPUT
        function GUSER_answer {
            read -p "Continue? [Y/N] : " USER_answer

            while [ -z "$USER_answer" ]; do
                    read -p "Continue? [Y/N] : " USER_answer
            done

            while [ "$USER_answer" != "Y" ] && [ "$USER_answer" != "N" ]; do
                    read -p "Continue? [Y/N] : " USER_answer
            done
        }
    # GET USER INPUT

    # START SCRIPT
        # Check if the script is in a WordPress directory
        if [ ! -e "wp-config.php" ]; then
        echo "Not in a WordPress website directory."
        exit 1
        fi

        # Extract database configuration
            get_info_DB 'DB_NAME' 'database_name'
            get_info_DB 'DB_USER' 'user_name'
            get_info_DB 'DB_PASSWORD' 'database_password'
        # Extract database configuration

        # VARS
            sql_NAME="$(openssl rand -base64 $((20*3/4)) | tr -d '[:space:][:punct:]').sql"
        # VARS

        # COLOR
            ColoRs ErrS red !!!
            ColoRs C_db_p cyan $database_password

            ColoRs C_db_u cyan $user_name

            ColoRs C_db_d cyan $database_name

            ColoRs C_sql_name cyan $sql_NAME

        # COLOR

        # SHOW PREVIEW
            echo -e "$ErrS ABOUT TO RUN THE FOLLOWING COMMAND: $ErrS"
            echo -e "#- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
            echo -e "# mysqldump -p$C_db_p -u $C_db_u $C_db_d > $C_sql_name <- export $C_db_d to $C_sql_name"
            echo -e "#- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -"
        # SHOW PREVIEW
        GUSER_answer

        if [ "$USER_answer" == "Y" ]; then
            Export_SQL
        elif [ "$USER_answer" == "N" ]; then
            echo "OK."
            exit 0
        else
            exit 1
        fi
    # START SCRIPT
# WP MANAGER
