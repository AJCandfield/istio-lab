# Repository instructions

## Infrastructure and service mesh

- Keep infrastructure and cluster-lifecycle components such as Kyverno and Karpenter outside the service mesh by default.
- Disable namespace injection and, when supported, reinforce it with workload-level injection exclusions.
- Mesh such components only when the integration is explicitly supported and a concrete requirement outweighs the added admission-path or cluster-recovery dependency. Document the reasons and validate API server connectivity, startup ordering, certificate handling, and outage recovery before enabling it.
