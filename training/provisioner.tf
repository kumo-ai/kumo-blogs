resource "kubernetes_manifest" "provisioner_gpu_provisioner" {
  manifest = {
    "apiVersion" = "karpenter.sh/v1alpha5"
    "kind" = "Provisioner"
    "metadata" = {
      "name" = "gpu-provisioner"
    }
    "spec" = {
      "provider" = {
        "blockDeviceMappings" = [
          {
            "deviceName" = "/dev/xvda"
            "ebs" = {
              "deleteOnTermination" = true
              "iops" = 3000
              "throughput" = 125
              "volumeSize" = "100Gi"
              "volumeType" = "gp3"
            }
          },
        ]
        "securityGroupSelector" = {
          "karpenter.sh/discovery/training-cluster" = "training-cluster"
        }
        "subnetSelector" = {
          "Name" = "training-cluster-vpc-private*"
        }
        "tags" = {
          "karpenter.sh/discovery/training-cluster" = "training-cluster"
        }
      }
      "requirements" = [
        {
          "key" = "node.kubernetes.io/instance-type"
          "operator" = "In"
          "values" = [
            "g4dn.xlarge",
            "g4dn.4xlarge",
            "g4dn.8xlarge",
            "g4dn.16xlarge",
          ]
        },
        {
          "key" = "karpenter.sh/capacity-type"
          "operator" = "In"
          "values" = [
            "spot",
            "on-demand",
          ]
        },
        {
          "key" = "kubernetes.io/arch"
          "operator" = "In"
          "values" = [
            "amd64",
          ]
        },
      ]
      "taints" = [
        {
          "effect" = "NoSchedule"
          "key" = "nvidia.com/gpu"
        },
      ]
      "ttlSecondsAfterEmpty" = 30
    }
  }
}
