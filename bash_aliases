alias be='bundle exec'
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias cd..='cd ..'

alias candi-export='mysqldump -h candiprod-replica.cvy6bjrzi4ri.us-east-1.rds.amazonaws.com -u root -pyida8kbpxp9i5tb2 --ignore-table=candiprod.zoyto_requests --ignore-table=candiprod.zoyto_responses --ignore-table=candiprod.audit_logs candiprod  > ~/Documents/Data\ Warehouse/candi_export.sql'
