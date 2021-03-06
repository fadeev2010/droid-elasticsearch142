include_attribute "droid-elasticsearch142::default"
include_attribute "droid-elasticsearch142::nginx"

# Try to load data bag item 'elasticsearch/aws' ------------------
#
users = Chef::DataBagItem.load('elasticsearch', 'users')[node.chef_environment]['users'] rescue []
# ----------------------------------------------------------------

# === NGINX ===
# Allowed users are set based on data bag values, when it exists.
#
# It's possible to define the credentials directly in your node configuration, if your wish.
#
default.elasticsearch142[:nginx][:server_name]    = "elasticsearch"
default.elasticsearch142[:nginx][:port]           = "8080"
default.elasticsearch142[:nginx][:dir]            = ( node.nginx[:dir]     rescue '/etc/nginx'     )
default.elasticsearch142[:nginx][:user]           = ( node.nginx[:user]    rescue 'nginx'          )
default.elasticsearch142[:nginx][:log_dir]        = ( node.nginx[:log_dir] rescue '/var/log/nginx' )
default.elasticsearch142[:nginx][:users]          = users
default.elasticsearch142[:nginx][:passwords_file] = "#{node.elasticsearch142[:path][:conf]}/passwords"

# Deny or allow authenticated access to cluster API.
#
# Set this to `true` if you want to use a tool like BigDesk
#
default.elasticsearch142[:nginx][:allow_cluster_api] = false

# Allow responding to unauthorized requests for `/status`,
# returning `curl -I localhost:9200`
#
default.elasticsearch142[:nginx][:allow_status] = false

# Other Nginx proxy settings
#
default.elasticsearch142[:nginx][:client_max_body_size] = "50M"
default.elasticsearch142[:nginx][:location] = "/"
