# aws-metadata-export

* home :: https://github.com/jf647/aws-metadata-export
* license :: [MIT](http://opensource.org/licenses/MIT)
* gem version :: [![Gem Version](https://badge.fury.io/rb/aws-metadata-export.png)](http://badge.fury.io/rb/aws-metadata-export)
* build status :: [![Circle CI](https://circleci.com/gh/jf647/aws-metadata-export.svg?style=svg)](https://circleci.com/gh/jf647/aws-metadata-export)

## DESCRIPTION

Exports AWS EC2 Instance metadata and tags to files

## OVERVIEW

aws-metadata-export is a utility to dump AWS EC2 instance metadata and tags
to files.  This makes it easier to predicate behaviour of userdata scripts
on the value of tags.  For example, in a userdata script:

    aws-metadata-export
    instance_id=$(cat /var/run/aws_metadata_export/instance_id)
    foo_tag_value=$(cat /var/run/aws_metadata_export/tags/foo)
    if [ -f /var/run/aws_metadata_export/tags/bar ]
    then
      echo 'tag bar is set'
    fi

The following instance data files are written:

* instance_id
* local_ipv4
* region
* az

Tags are written to the a 'tags' directory.  Each file is the name of a
tag and the contents of that file is the value of the tag.  To disable
tag export, pass `--no-tags` to the command line.

## INSTALLATION

    gem install aws-metadata-export

This would typically be done in your AMI preparation process, but can be
done in your userdata if the instance has a path to rubygems.org.

## IAM INSTANCE PERMISSIONS

Tags are not exported through EC2 instance data, so the EC2 API must be
used to fetch them.  As such, the IAM permission `ec2:DescribeInstances`
must be available via an IAM instance profile and role.

If you wish to use the gem on a node without an IAM instance profile,
you can pass `export_tags: false` to the export method or `--no-tags` to
the CLI, in which case only the metdata that can be fetched from the
metadata endpoint will be exported.

## ENVIRONMENT VARIABLES

Two environment variables can be used to vary behavior of the utility.

* AWS_METADATA_EXPORT_DIR if set changes the output directory from `/var/run/aws_metadata_export` to something else
* AWS_METADATA_EXPORT_UMASK if set changes the umask used to create the directory and write the files from the default of 00077 to something else

## AUTHOR

James FitzGibbon - james@nadt.net

## LICENSE

Copyright (c) 2015 James FitzGibbon

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
