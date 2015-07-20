#!/bin/bash (source)

Import File
Import String

function Get_Archive_Format() {
   Parameters "$@" archive
   local format=$(Downcase "${archive}" | sed -r \
   -e "s/.*\.(tar\.bz|tbz)$/tarbzip/" \
   -e "s/.*\.(tar\.bz2|tbz2)$/tarbzip2/" \
   -e "s/.*\.(tar\.(gz|Z)|tgz)$/targzip/" \
   -e "s/.*\.(cpio\.(gz|Z)|tgz)$/cpiogzip/" \
   -e "s/.*\.tar\.(lzma|7z)$/tarlzma/" \
   -e "s/.*\.tar\.xz$/tarxz/" \
   -e "s/.*\.bz$/bzip/" \
   -e "s/.*\.bz2$/bzip2/" \
   -e "s/.*\.gz$/gzip/" \
   -e "s/.*\.Z$/gzip/" \
   -e "s/.*\.tar$/tar/" \
   -e "s/.*\.(lzma|7z)$/lzma/" \
   -e "s/.*\.xz$/xz/" \
   -e "s/.*\.zip$/zip/" \
   -e "s/.*\.cpio$/cpio/")
   if [ "${format}" == "${file}" ]
   then
      format=$(file --mime --uncompress --brief "${archive}" | sed -r \
         -e 's,.*application/x-([^ ;]*).*application/x-([^\) ;]*).*,\1\2,' \
         -e 's,.*application/x-([^ ;]*).*,\1,')
   fi
   echo "${format}"
}

function needs_archiver() {
   Parameters "$@" format archiver
   Executable_Exists_In_Path ${archiver} || {
      Log_Normal "$(CommandNotFound ${archiver} 2>&1)"
      Log_Terse "Format ${format} requires ${archiver}"
      return 1
   }
}

function Unpack_Archive() {
   # Unfortunatly Parameters can't assign the "tail"
   #Parameters "$@" archive targetdirectory force files
   local archive=${1##*/};
   local path=${1%/*}; shift;
   local targetdirectory=$1; shift;
   local force=$1; shift;
   local files="${@}"
   [ -n "${targetdirectory}" ] &&  mkdir -p "${targetdirectory}"
   case `Get_Archive_Format "${archive}"` in
   tarbzip)
      ( needs_archiver "tar+bzip" bunzip && needs_archiver "tar+bzip" tar ) || return 2
      bunzip --keep --decompress --stdout "${path}/${archive}" | tar --extract --verbose ${targetdirectory:+-C --file=- "${targetdirectory}"} ${force:+--overwrite} ${files:+"${files[@]}"}
      ;;
   tarbzip2)
      ( needs_archiver "tar+bzip2" bunzip2 && needs_archiver "tar+bzip2" tar ) || return 2
      bunzip2 --keep --decompress --stdout "${path}/${archive}" | tar --extract --verbose ${targetdirectory:+-C "${targetdirectory}"} --file=- ${force:+--overwrite} ${files:+"${files[@]}"}
      ;;
   targzip)
      ( needs_archiver "tar+gzip" gunzip && needs_archiver "tar+gzip" tar ) || return 2
      gunzip --decompress --stdout "${path}/${archive}" | tar --extract --verbose ${targetdirectory:+-C "${targetdirectory}"} ${force:+--overwrite} --file=- ${files:+"${files[@]}"}
      ;;
   tarlzma)
      ( needs_archiver "tar+lzma" lzma && needs_archiver "tar+lzma" tar ) || return 2
      lzma --stdout --decompress --keep "${path}/${archive}" | tar --extract --verbose ${targetdirectory:+-C "${targetdirectory}"} ${force:+--overwrite} --file=- ${files:+"${files[@]}"}
      ;;
   tarxz)
      ( needs_archiver "tar+xz" xz && needs_archiver "tar+xz" tar ) || return 2
      xz --stdout --decompress --keep "${path}/${archive}" | tar --extract --verbose ${targetdirectory:+-C "${targetdirectory}"} ${force:+--overwrite} --file=- ${files:+"${files[@]}"}
      ;;
   cpiogzip)
      ( needs_archiver "cpio+gzip" cpio && needs_archiver "cpio+gzip" gzip ) || return 2
      gunzip --decompress --stdout "${path}/${archive}" | cpio --extract --make-directories ${force:+--unconditional} --preserve-modification-time ${files:+--pattern-file=<(echo "${files[@]}" | sed 's/\ /\n/g')}
      ;;
   bzip)
      needs_archiver "bzip" bunzip || return 2
      bunzip --decompress --keep --stdout "${path}/${archive}" > "${targetdirectory}/${archive%%.bz}"
      ;;
   bzip2)
      needs_archiver "bzip2" bunzip2 || return 2
      bunzip2 --decompress --keep --stdout "${path}/${archive}" > "${targetdirectory}/${archive%%.bz2}"
      ;;
   gzip)
      needs_archiver "gzip" gzip || return 2
      gunzip --decompress --stdout "${path}/${archive}" > "${targetdirectory}/${archive%%.gz}"
      ;;
   tar)
      needs_archiver "tar" tar || return 2
      tar --extract --verbose --file "${path}/${archive}" ${targetdirectory:+-C "${targetdirectory}"} ${force:+--overwrite} ${files:+"${files[@]}"}
      ;; 
   lzma)
      needs_archiver "lzma" lzma || return 2
      lzma --decompress --keep --stdout "${path}/${archive}" > "${targetdirectory}/${archive%%.lzma}"
      ;;
   xz)
      needs_archiver "xz" xz || return 2
      xz --decompress --keep --stdout "${path}/${archive}" > "${targetdirectory}/${archive%%.lzma}"
      ;;
   cpio)
      needs_archiver "cpio" cpio || return 2
      cpio --extract --make-directories --preserve-modification-time ${force:+--unconditional} -I "${path}/${archive}" ${files:+--pattern-file=<(echo "${files[@]}" | sed 's/\ /\n/g')}
      ;;
   zip)
      needs_archiver "zip" unzip || return 2
      unzip ${force:+-o} "${path}/${archive}" ${files:+${files[@]}} ${targetdirectory:+-d "${targetdirectory}"}
      ;;
   *)
      Log_Error "Unknown format: ${path}/${archive}"
      return 3
      ;;
   esac
}

function List_Archive_Files() {
   Parameters "$@" archive verbose
   case `Get_Archive_Format "${archive}"` in
   tarbzip)
      bunzip --keep --decompress --stdout | tar --list
      ;;
   tarbzip2)
      bunzip2 --keep --decompress --stdout "${archive}" | tar --list
      ;;
   targzip)
      gunzip --decompress --stdout "${archive}" | tar --list
      ;;
   tarlzma)
      lzma --stdout --decompress --keep "${archive}" | tar --list
      ;;
   tarxz)
      xz --stdout --decompress --keep "${archive}" | tar --list
      ;;
   bzip)
      echo $(basename "${archive}") | sed -e "s/\(.*\)\.bz$/\1/"
      ;;
   bzip2)
      echo $(basename "${archive}") | sed -e "s/\(.*\)\.bz2$/\1/"
      ;;
   gzip)
      gunzip --list --stdout "${archive}"
      ;;
   tar)
      tar --list --file "${archive}"
      ;;
   lzma)
      echo $(basename "${archive}") | sed -e "s/\(.*\)\.lzma$/\1/"
      ;;
   cpio)
      cpio --list -I "${archive}"
      ;;
   zip)
      unzip -Z -1 "${archive}"
      ;;
   esac
}

