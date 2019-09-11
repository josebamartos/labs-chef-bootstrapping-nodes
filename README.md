# Chef Lab - Apache web servers

Simple lab to test the basic interaction between `Chef Infra Server`, `Chef Nodes` and `Chef Workstation`.

We will manage infrastructure using `Vagrant`, who will use `Virtualbox` to provision it as defined in [Vagrantfile](Vagrantfile), creating the hosts below:

| Hostname      | IP          | Description                                      |
| ------------- | ----------- | ------------------------------------------------ |
| chef-server   | 10.10.10.10 | Chef Server                                      |
| chef-node-01  | 10.10.10.11 | Node where Apache 2 will be installed by Chef    |
| chef-node-02  | 10.10.10.12 | Node where Apache 2 will be installed by Chef    |

There is one more host involved, your computer, which will act as `Chef Workstation`. This lab is designed to be completed working only from the workstation, who will communicate `Chef Infra Server` with the `Chef Nodes` to bootstrap them, performing an installation of Apache HTTP Server 2 from the OS official repositories.

## Dependencies

1. [Virtualbox](https://www.virtualbox.org)
1. [Vagrant](https://www.vagrantup.com)
2. [ChefDK](https://downloads.chef.io/chefdk)

## Let's Rock!

### Download repo and provision infrastructure

Clone repository:

```
$ git clone https://gitlab.com/josebamartos/lab-chef-bootstrapping-nodes
$ cd lab-chef-bootstrapping-nodes
```

Provision infrastructure with Vagrant:

```
$ vagrant up
```

### Connection between a Chef Workstation and Chef Infra Server

Once infrastructure is created:

1. Visit https://chef-server with username `manager` and password `P4ssW0rd..` as credentials
1. Go to tab `Administration`
1. In the table below, select organization `labs-chef`
1. Click over item `Starter Pack` of the left menu
1. Click button `Download Starter Kit`
1. Do the same in the confirmation windows with button `Proceed`
1. Download of file `chef-starter.zip` will start, save it into the root directory of the lab: `lab-chef-bootstrapping-nodes`.

:information_source: Starter Kit is a Chef repository which comes configured to communicate with Chef Infra Server out of the box via clients like Knife. Inside directory chef-repo resides subdirectory .chef, which contains Knife configuration file knife.rb and client key user.pem.

Extract containing chef-repo directory and enter into:

```
$ unzip chef-starter.zip
$ cd chef-repo
```

List nodes connected to Chef Infra Server:

```
$ knife client list
ERROR: SSL Validation failure connecting to host: chef-server - SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate)
ERROR: Could not establish a secure connection to the server.
Use `knife ssl check` to troubleshoot your SSL configuration.
If your server uses a self-signed certificate, you can use
`knife ssl fetch` to make knife trust the server's certificates.

Original Exception: OpenSSL::SSL::SSLError: SSL Error connecting to https://chef-server/organizations/chef-labs/clients - SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate)
```

This error is produced for SSL misconfiguration or self-signed certificates. To solve it, we'll download and check SSL certificates from the server:

```
$ knife ssl fetch
$ knife ssl check
$ chef verify
```

# Create a cookbook and upload to Chef Infra Server

Now we will create a new cookbok to provision the nodes with Apache 2:

```
$ chef generate cookbook cookbooks/apache
```

Let's create a new recipe for this cookbook:

```
$ vim cookbooks/apache/recipes/server.rb
```

With the content below:

```
package 'httpd'

service 'httpd' do
  action [:enable, :start]
end
```

Upload `apache` cookbook to Chef Infra Server:

```
$ knife cookbook upload apache
```

# Bootstrap new Chef Nodes

Now we'll bootstrap the nodes to connect them with Chef Infra Server:

```
$ knife bootstrap chef-node-01 --sudo --no-host-key-verify -N chef_node_01 -x vagrant -i ../.vagrant/machines/chef_node_01/virtualbox/private_key -r "recipe[apache::server]"
```

```
$ knife bootstrap chef-node-02 --sudo --no-host-key-verify -N chef_node_02 -x vagrant -i ../.vagrant/machines/chef_node_02/virtualbox/private_key -r "recipe[apache::server]"
```

Running the previous commands, on each node Chef Client was installed and after that recipe `server` from cookbook `apache` was executed. This is the end of the lab.

# Test the resulting infrastructure

Visit the following addresses to verify the installation:

| Address             | Expected result                                        |
| ------------------- | ------------------------------------------------------ |
| https://chef-server | Web interface of Chef Infra Server                     |
| http://chef-node-01 | Default `index.html` of Apache 2 HTTP Server on CentOS |
| http://chef-node-02 | Default `index.html` of Apache 2 HTTP Server on CentOS |

## Thanks

Thanks to Hector Yeomans for sharing his project [chef-lab](https://github.com/hyeomans/chef-lab), in which structure is based this lab.