#!/bin/bash
#########Script :GDG-Backup-Restore##############
#########Author :Rakesh Aavula     ##############
#########Date   :10/03/2011        ##############
#########Version:1.0               ##############

### to take second argument in case of -l option only"
usageHelp="Usage: $0"
usageHelpError="Usage: $0 requires atleast one parameter, please use -h option to see more options available"
Help="-h Help usage for the backup utility"
Archieve="-d <days> , it will find the files which are older than <days> and stores them at Dest(DIRECTORY)"
Restore="-r <days> , it search for the archieve of <days> and restores them to Restore(DIRECTORY)"

badOptionHelp="Option not recognised"
Src="/microfocus/prod/batch/system/data"
Restore_Dir=$Src
Dest="/microfocus/prod/batch/system/data/archive/Test"
printHelpAndExit()
{
    echo ""
    echo "$usageHelp"
    echo ""
    echo "$Help"
    echo ""
#    echo "$List"
    echo "$Archieve"
    echo ""
    echo "$Restore"
    echo ""
    exit 1
}
printErrorHelpAndExit()
{
       echo $usageHelpError
       echo "Exiting $0"
    exit 1;
}

####Future implementation send an email for successful archieving


InitRoutine()
{
    set `pwd`
    Pwd=$1
#    Now=$(date +"%F")
#    Backup="Backup-$Now"
#    BackupName="Backup-$Now"
#    BackupLogName="Backup-$Now.log"
    Target=$Dest
    List="$Target/Commulative.txt"
    
    TargetDir="$Target"
    

    
    TargetDir_Arch=$TargetDir/Archieve_$Days
    TarOpts="-zcvf"

#    echo $List
#    echo Target DIr is $TargetDir
#    echo Days :$Days
    
}

Backup()
{
    #echo "in Backuproutine"
    InitRoutine 0;
    
    if [ $Days -le "0" ] ; then
        echo " $Days  is Invalid"
        exit 1;
    fi

    echo "days dir is" $TargetDir_Arch
    if [ ! -d $TargetDir_Arch ]; then
    mkdir $TargetDir_Arch
    echo "$TargetDir_Arch created"
    else
    echo "$TargetDir_Arch Already Exists "

        if [ -f $TargetDir_Arch/Archieve_$Days.tar.gz ]; then
            echo "**********************************************************"
            echo "$TargetDir_Arch/Archieve_$Days.tar.gz already exists"
            ls -l $TargetDir_Arch/Archieve_$Days.tar.gz
            echo "**********************************************************"
    
            echo " Do you want to see the list of files in this Archieve ( y / n )"

            echo -n "(default 'n)',use 'e' to exit) :"

        read Choice        
        
        case $Choice in     
            n|N|"")
                 Flag="N";
                 exit 1;;
                y)  Flag=Y;
                 tar -tvf $TargetDir_Arch/Archieve_$Days.tar.gz | awk '{print $6}'  > Check_list.txt;
                 echo " Files count  :" wc -l Check_list.txt
                 echo " Check the file Check_list.txt at location :" pwd;
                 exit 1;;
                e)  echo "exiting $0..";
                 exit 1;;    

        esac

        fi

    fi
    
}

ArchieveNow()
{
##    TargetDir_Arch=$TargetDir/Archieve_$Days
    echo "Starting the $0 for $Src Backup at $TargetDir_Arch "

cd $Src

#echo "------------------------------------------------------" >> $List
    find ./ -type f -mtime +$Days -name "*.G00*"  >> $List
#echo "------------------------------------------------------" >> $List
        
find ./ -type f -mtime +$Days -name "*.G00*" | tar -zcv -f $TargetDir_Arch/Archieve_$Days.tar.gz -T -
echo "Return Code :$? " >>$TargetDir_Arch/Archieve_$Days.log 2>&1
echo -n "disk usage :"
du -h $TargetDir_Arch/Archieve_$Days.tar.gz
echo "$0 Completed Successfully ,check Archieve_$Days.log for more details"            
        
}

Restore()
{    
##initialization
         InitRoutine 0;
    
    if [ $Res_days -le "0" ]; then
        echo "$Res_days is Invalid"
        exit 1;
    fi


## $Dest contains the archieves

          echo "Starting Restore"
    
    
        Res_Days=$Res_days;

        echo -e "Looking for Archieve_$Res_Days ... "
        if [ ! -d $TargetDir/Archieve_$Res_Days ]; then
            echo $TargetDir/Archieve_$Res_Days
            echo -e "Archieve_$Res_Days \t   [ NOT FOUND ] "
            echo -e "Exiting \t [ Done ]"
            exit 1;
        else
            echo -e "Archieve_$Res_Days \t   [ FOUND ] "
            
        fi
##egrep -v -f input.txt original.txt > output.txt  // to updat teh cummulative list
 #Delete list
        tar tvf $TargetDir/Archieve_$Res_Days/Archieve_$Res_Days.tar.gz | awk '{print $6}' > /tmp/gdg/deletelist
        echo -n "Number of Files to Restore are : ";
        wc -l /tmp/gdg/deletelist
     
        tar -zxvf $TargetDir/Archieve_$Res_Days/Archieve_$Res_Days.tar.gz -C $Src >> $TargetDir/Archieve_$Res_Days/Restore_$Res_Days.log
        
        echo " **** Commulative files  ****** "
        echo -e " Backing up the Existing Cummulative.txt "

        cp $Target/Commulative.txt /tmp/gdg/Commulative_bak_at_$Res_Days.txt
        
        sdiff -s $Target/Commulative.txt /tmp/gdg/deletelist | cut -d "<" -f1 > /tmp/gdg/Commulative_after_$Res_Days.txt

#        grep -v -f /tmp/gdg/deletelist $Target/Commulative.txt > /tmp/gdg/Commulative_after_$Res_Days.txt
        
        mv /tmp/gdg/Commulative_after_$Res_Days.txt $Target/Commulative.txt            
        
        echo "$0 Completed Successfully ,check $TargetDir/Archieve_$Res_Days/Restore_$Res_Days.log for more details"            
        
        exit 1;
    
}
 
if [ -z $1 ]; then
    printErrorHelpAndExit 0;
    exit 1;
fi    

if [ ! -z $3 ] || [ ! -z $4 ]; then
    echo ""
    echo "Illegal Usage of $0, $3 $4 are Illegal with -r / -d "
    printHelpAndExit 0;
    exit 1;
fi    





while getopts "hd:r:" optionName; do
    case "$optionName" in
             h)    printHelpAndExit 0;;
             d) Days="$OPTARG";             
             Backup 0;
             ArchieveNow 0    ;;                       
             r) Res_days="$OPTARG";
             Restore 0 ;;    
             *) printErrorHelpAndExit "$badOptionHelp";;
    esac
done


