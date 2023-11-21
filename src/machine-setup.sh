# Create a test function for sh vs. bash detection.  The name is
# randomly generated to reduce the chances of name collision.
__ms_function_name="setup__test_function__$$"
eval "$__ms_function_name() { /bin/true ; }"

# Determine which shell we are using
__ms_ksh_test=$( eval '__text="text" ; if [[ $__text =~ ^(t).* ]] ; then printf "%s" ${.sh.match[1]} ; fi' 2> /dev/null | cat )
__ms_bash_test=$( eval 'if ( set | grep '$__ms_function_name' | grep -v name > /dev/null 2>&1 ) ; then echo t ; fi ' 2> /dev/null | cat )

if [[ ! -z "$__ms_ksh_test" ]] ; then
    __ms_shell=ksh
elif [[ ! -z "$__ms_bash_test" ]] ; then
    __ms_shell=bash
else
    # Not bash or ksh, so assume sh.
    __ms_shell=sh
fi

# Note: this script only supports bash on GAEA. That is due to
# a limitation of GAEA's own system init scripts.

target=""
USERNAME=`echo $LOGNAME | awk '{ print tolower($0)'}`

# Disable -e (abort on non-zero exit status) -u (abort on empty or
# uninitialized variables) and -x (print every command executed)
# because they can break system scripts.
__ms_set=$-
set +eux

if [[ -d /lfs4 ]] ; then
    # We are on NOAA Jet
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        echo load the module command 1>&2
        source /apps/lmod/lmod/init/$__ms_shell
    fi
    target=jet
    module purge
elif [[ -d /scratch1/NCEPDEV ]] ; then
    # We are on NOAA Hera
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        echo load the module command 1>&2
        source /apps/lmod/lmod/init/$__ms_shell
    fi
    target=hera
    module purge
elif [[ -d /work/noaa ]] ; then
    # We are on MSU Orion
    if ( ! eval module help > /dev/null 2>&1 ) ; then
	echo load the module command 1>&2
        source /apps/lmod/lmod/init/$__ms_shell
    fi
    target=orion
    module purge
    module use /apps/modulefiles/core
    module use /apps/contrib/modulefiles
    module use /apps/contrib/NCEPLIBS/lib/modulefiles
    module use /apps/contrib/NCEPLIBS/orion/modulefiles
elif [[ -d /lfs/h1 && -d /lfs/h2 ]] ; then
    target=wcoss2
    . $MODULESHOME/init/sh
elif [[ -d /glade ]] ; then
    # We are on NCAR Yellowstone
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        echo load the module command 1>&2
        . /usr/share/Modules/init/$__ms_shell
    fi
    target=yellowstone
    module purge
elif [[ -d /lustre && -d /ncrc ]] ; then
    module purge
    # Unset the read-only variables $PELOCAL_PRGENV and $RCLOCAL_PRGENV
    gdb -ex 'call (int) unbind_variable("PELOCAL_PRGENV")' \
        -ex 'call (int) unbind_variable("RCLOCAL_PRGENV")' \
        --pid=$$ --batch
    
    # Reload system default modules:
    source /etc/bash.bashrc.local

    # Also load EPIC's lmod:
    source /lustre/f2/dev/role.epic/contrib/Lmod_init.sh

    if ( head /proc/cpuinfo | grep EPYC ) ; then
        target=gaea_c5
    else
        target=gaea
    fi
elif [[ "$(hostname)" =~ "odin" ]]; then
    target="odin"
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

# Restore shell settings
set -$__ms_set

unset __ms_set
unset __ms_shell
unset __ms_ksh_test
unset __ms_bash_test
unset $__ms_function_name
unset __ms_function_name
