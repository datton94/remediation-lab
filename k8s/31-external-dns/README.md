# External-dns
* Source: https://github.com/kubernetes-sigs/external-dns/tree/v0.10.1
* Documentation: https://github.com/kubernetes-sigs/external-dns/blob/v0.10.1/docs/tutorials/alb-ingress.md

## What does External-dns do?
In general, `external-dns` will scan all `ingress` in the cluster and create the A Record in the suitable `Hostzone` of `Route53`. Thanks to this feature, we don't need to create records in `Route53` manually for EKS anymore

The detail documentation is in the link above, it's easy to understand.
