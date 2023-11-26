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



</script>

<Summaries year={year} items={summaries} participants={participants} />
<PerDayGraph items={summaries} />
<CumulativeGraph items={summaries} />
<PercentRuntimeGraph items={summaries} />
