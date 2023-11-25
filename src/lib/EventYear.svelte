<script lang="ts">
  import type { Summary } from './common'
  import Summaries from './Summaries.svelte'
  import CumulativeGraph from './CumulativeGraph.svelte'
  import PercentRuntimeGraph from './PercentRuntimeGraph.svelte'
  import PerDayGraph from './PerDayGraph.svelte'

  let base_url = import.meta.env.VITE_API_BASE;

  export let year: number;

  let items: Summary[] = [];

  fetch(`${base_url}/api/v1/summaries?year=${year}`)
    .then((response) => response.json())
    .then((json) => (items = json));
</script>

<Summaries year={year} items={items} />
<PerDayGraph items={items} />
<CumulativeGraph items={items} />
<PercentRuntimeGraph items={items} />
