# Terraform Hetzner Cloud Swarm

## 🎯 About

Get a cheap Swarm cluster in less than **5 minutes**, with optional HA support, with easy configuration setup through simple Terraform variables, 💯 GitOps compatible !

This opinionated Terraform template will generate a ready-to-go cloud infrastructure through Hetzner Cloud provider, with a ready-to-go initialized Docker Swarm cluster, the most lightweight container's orchestrator.

Additional managers and workers can be easily added thanks to terraform variables, even after initial setup for **easy upscaling**. Feel free to fork this project in order to adapt for your custom needs.

Check [K3S provider](https://github.com/okami101/terraform-hcloud-k3s) for a full-featured, but more resource consuming, orchestrator based on Kubernetes distribution.

### Networking and firewall

All nodes including LB will be linked with a proper private network as well as **solid firewall protection**. For admin management, only the 1st main manager (bastion) node will have open port only for SSH (configurable), with **IP whitelist** support. Other internal nodes will be accessed by SSH Jump.

Hetzner Load Balancer (optional) can be used for any external public access to your cluster. You have 2 options for LB :

* Put it front of **managers**, so you need at least 3 managers for HA support (odd number mandatory for quorum)
* Put it front of **workers**, so you need at least 2 workers for HA support. In this case, 1 single manager is required which is the far HA cheaper option.

Note that if you use the worker option, and if you use Traefik as proxy for route detection, you **MUST** configure it for using the **manager docker API endpoint**, otherwise it will not be able to detect newly added services. You can use **Socat** as simple socket proxy for this purpose.

### OS management

This Terraform template includes **[Salt Project](https://docs.saltproject.io)** as well for easy global OS management of the cluster through ssh, perfect for upgrades in one single time !

## ✅ Requirements

Before starting, you need to have :

1. A Hetzner cloud account.
2. A `terraform` client.
3. A `hcloud` client.
4. A `docker` client.

On Windows :

```powershell
scoop install terraform hcloud
```

## 🏁 Starting

### Prepare

The first thing to do is to prepare a new hcloud project :

1. Create a new **EMPTY** hcloud empty project.
2. Generate a **Read/Write API token key** to this new project according to [this official doc](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).

### Setup

Now it's time for initial cluster setup.

1. Copy [this swarm config example](swarm.tf.example) into a new empty directory and rename it `swarm.tf`.
2. Execute `terraform init` in order to install the required module
3. Replace all variables according your own needs.
4. Finally, use `terraform apply` to check the plan and initiate the cluster setup.

## Usage

### Access

Once terraform installation is complete, terraform will output the SSH config necessary to connect to your cluster for each node as well as following public IPs :

| Variable     | Description                                            |
| ------------ | ------------------------------------------------------ |
| `bastion_ip` | Bastion IP for OS and Docker swarm management          |
| `lb_ip`      | Load Balancer IP to use for any external public access |
| `lb_id`      | Load Balancer ID to use for attaching any services     |

Copy the SSH config to your own SSH config, default to `~/.ssh/config`. After few minutes, you can use `ssh <cluster_name>` in order to log in to your main manager node. For other nodes, the first manager node will be used as a bastion for direct access to other nodes, so use `ssh <cluster_name>-worker-01` to directly access to your *worker-01* node.

### Salt

Once logged to your bastion, don't forget to active *Salt*, just type `sudo salt-key -A` in order to accept all discovered minions. You are now ready to use any `salt` commands for global OS management, as `sudo salt '*' pkg.upgrade` for global OS upgrade in one single time.

> If salt-key command is not existing, wait few minutes as it's necessary that cloud-init has finished his job.

### Docker Swarm

#### Join nodes

By default, and because there is sadly no possibility to set a custom token for swarm, you must join all managers and workers node in order to have fully ready cluster. When logged to bastion, use :

* `docker swarm join-token worker` to print command to launch in every worker nodes.
* `docker swarm join-token manager` to print command to launch in every manager nodes.

Use `docker node ls` to check that all nodes are correctly joined to the cluster.

Finally, for remote usage from docker CLI through a secured SSH tunnel, you can use following command from your local machine :

```sh
# create a new docker context
docker context create --docker host=ssh://<cluster_name> --description="My Swarm cluster" my-swarm-cluster

# use it
docker context use my-swarm-cluster

# check it
docker info
docker node ls
```

#### Upscaling and downscaling

You can easily add or remove nodes by changing the `count` variable of each worker or manager. Then use `terraform apply` to apply the changes.

* When adding, the new manager or worker node will be automatically created, but you still need to join it to the cluster by using above related command. Don't also forget to accept the new minion with `sudo salt-key -A`.

## 📝 License

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
