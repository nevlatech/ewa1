#!xtclsh
## 
## Written by Eric Anderson, 2012
##
## Property extractor, revised from Xilinx Answer Record AR30962
## http://www.xilinx.com/support/answers/30962.htm
## 

proc get_properties {props_name} {
    upvar $props_name props
    set props [list]
    set processes [project get_processes]
    set projName [project get name]
    puts stderr "Reading process properties from $projName"
    foreach proc_iter $processes {
	puts stderr "Process \"$proc_iter\" "
	set properties [project properties -process $proc_iter]
	set prop_list [list]
	puts stderr "  All properties: $properties" ;# DEBUG
	foreach prop_iter $properties {
	    puts stderr "  Property \"$prop_iter\"" ;# DEBUG
	    set val [project get $prop_iter -process $proc_iter]
	    puts stderr "  $prop_iter: $val" ;#DEBUG
	    lappend prop_list [list $prop_iter ":" $val]
	}
	lappend props [list $proc_iter $prop_list]
	unset prop_list
    }
}

## XXX not used, but maybe useful?
proc handleSpecialCharsImpl {x chr} {
    upvar $x str
    set lastmatch 0
    while {[set idx [string first $chr $str $lastmatch]] >= 0} {
	set lastmatch [expr {$idx + 2}]
	set str [string replace $str $idx $idx "\\$chr"]
    }
}

## XXX not used, but maybe useful?
proc handleSpecialChars {x} {
    upvar $x str
    handleSpecialCharsImpl str \\
	handleSpecialCharsImpl str \$
}


## Just write the internal TCL representation out as a string.  We'll
## do any further processing in a more agreeable language.
proc simple_text_dump {props fileName} {
    set fid [open $fileName w]
    puts $fid $props
    close $fid
    puts stderr "Dumped properties to file $fileName"
}

proc open_project {fname} {
    puts stderr "Attempting to open $fname"
    if [catch {project open $fname} open_err] {
	puts stderr "Error while attempting to open '$fname':\n$open_err"
	exit -1
    }    
    # Verify that a project is open
    if [catch {project get name} iseName] {
	error $iseName
    }
    puts stderr "Project opened"
}


# Normalize paths because xtclsh may change directories, causing
# relative paths to be misinterpreted.
set projfile [file normalize [lindex $argv 0]]
set out_file  [file normalize [lindex $argv 1]]

open_project $projfile
get_properties properties
simple_text_dump $properties $out_file
