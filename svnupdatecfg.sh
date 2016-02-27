#!/bin/bash
#svnupdatecfg.sh 

CONFIG_DIR="/opt/configurations"
SVN_DIR="/opt/svn/workingcopy"
REPO="configurations"
WORKING_DIR="$SVN_DIR/$REPO"
SVNOPTIONS="--no-auth-cache --non-interactive --username <svn_username> --password <svn_password>"
UPDATE=0
NEWFILE=0
COPY=1
SVNCOMMIT=1
COMMENT="Nothing"
FORCECOMMIT=1

if [ -d "$CONFIG_DIR" ]; then
    
    for CFG_FILE in $(find $CONFIG_DIR -name "*.cfg")
    do
        SOURCE_FILE=`basename $CFG_FILE`
        TARGET_FILE="$WORKING_DIR/$SOURCE_FILE"
        FILESIZE=`stat -c %s $CFG_FILE` 
        if [ $FILESIZE -lt 1 ]; then
           #echo "File $CFG_FILE is zero size"
           continue
        fi

        if [ -f $TARGET_FILE ]; then
            #echo "Comparing $CFG_FILE and $TARGET_FILE" | logger
            #cmp -l $CFG_FILE $TARGET_FILE  > /dev/null 
            cmp $CFG_FILE $TARGET_FILE  > /dev/null 

            if [ $? -eq 1 ]; then
               echo "$0: Changes detected on $SOURCE_FILE" | logger
               if [ $COPY -gt 0 ]; then
                  cp $CFG_FILE $TARGET_FILE | logger
               fi
               UPDATE=1
            fi

        else
             echo "$0: Copying $SOURCE_FILE" | logger
             if [ $COPY -gt 0 ]; then
                cp $CFG_FILE $TARGET_FILE | logger
             fi
             NEWFILE=1
        fi
    done

    if [ $UPDATE -gt 0 ]; then
       COMMENT="Device configurations changes detected..."
       if [ $NEWFILE -gt 0 ]; then  
          COMMENT="New files uploaded..."
       fi  
       if [ $SVNCOMMIT -gt 0 ]; then  
          echo "$0: Commiting changes from $SVN_DIR/$REPO" | logger
          cd $SVN_DIR 
          chown -R www-data:subversion $REPO/*
          chmod -R 770 $REPO/*
          #svn add $REPO/*  >/dev/null 2>&1 
          #svn commit $REPO/* $SVNOPTIONS -m "`echo $COMMENT`" | logger
          svn add $REPO/*   
          svn commit $REPO/* $SVNOPTIONS -m "`echo $COMMENT`" 
       fi
    else
       echo "$0: No changes detected..." | logger
    fi

    if [ $FORCECOMMIT -gt 0 ]; then
       COMMENT="Device configurations changes detected..."
       echo "$0: Commiting changes from $SVN_DIR/$REPO" | logger
       echo "Committing $REPO with options $SVNOPTIONS and comment $COMMENT" | logger
       cd $SVN_DIR
       chown -R www-data:subversion $REPO/*
       chmod -R 770 $REPO/*
       svn commit $REPO/* $SVNOPTIONS -m "`echo $COMMENT`" | logger
    fi
fi
