<script lang="ts">
  import type { Summary, Participant } from './common'
  import Summaries from './Summaries.svelte'
  import CumulativeGraph from './CumulativeGraph.svelte'
  import PercentRuntimeGraph from './PercentRuntimeGraph.svelte'
  import PerDayGraph from './PerDayGraph.svelte'

  let base_url = import.meta.env.VITE_API_BASE;

  export let year: number;

  let summaries: Summary[] = [];
  let participants: Participant[] = [];

  fetch(`${base_url}/api/v1/summaries?year=${year}`)
    .then((response) => response.json())
    .then((json) => (summaries = json));

  fetch(`${base_url}/api/v1/participants?year=${year}`)
    .then((response) => response.json())
    .then((json) => (participants = json));

  let pipeline = `http://ci.papercode.net:8080/teams/main/pipelines/aoc${year}`

</script>

{#if year == 2022}
  <p>2022 is incomplete because it was run before the spec and new benchmarking,
  so it's missing some participants. It is included here to get a sense of what
  the reporting looks like.</p>
{:else}
  <br />
  <a href="{ pipeline }" target="_blank">CI Pipeline</a>
{/if}
<Summaries year={year} summaries={summaries} participants={participants} />
<PerDayGraph items={summaries} />
<CumulativeGraph items={summaries} />
<PercentRuntimeGraph items={summaries} />
