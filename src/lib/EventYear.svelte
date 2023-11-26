<script lang="ts">
  import type { Summary, Participant } from './common'
  import Summaries from './Summaries.svelte'
  import CumulativeGraph from './CumulativeGraph.svelte'
  import PercentRuntimeGraph from './PercentRuntimeGraph.svelte'
  import PerDayGraph from './PerDayGraph.svelte'
  import Checkbox from '@smui/checkbox'
  import FormField from '@smui/form-field';

  let base_url = import.meta.env.VITE_API_BASE;

  export let year: number;

  let summaries: Summary[] = [];
  let participants: Participant[] = [];

  $: filters = participants.map((x) => {
    return { name: x.name, disabled: false };
  });
  let selected = [];

  fetch(`${base_url}/api/v1/summaries?year=${year}`)
    .then((response) => response.json())
    .then((json) => (summaries = json));

  fetch(`${base_url}/api/v1/participants?year=${year}`)
    .then((response) => response.json())
    .then((json) => (participants = json))
    .then(() => {
      // this is a hack to exclude some very large runtimes from showing by
      // default for 2022 only
      selected = participants.filter((x) => year > 2022 || x.name != 'pting').map((x) => x.name);
    });

  $: filteredSummaries = summaries.filter((item) => selected.includes(item.participant));

  let pipeline = `http://ci.papercode.net:8080/teams/main/pipelines/aoc${year}`

</script>

<h3>Enabled participants</h3>
<div>
  {#each filters as option}
    <FormField>
      <Checkbox bind:group={selected} value={option.name} disabled={option.disabled} />
      <span slot="label">{option.name}</span>
    </FormField>
  {/each}
</div>

{#if year == 2022}
  <p>2022 is incomplete because it was run before the spec and new benchmarking,
  so it's missing some participants. It is included here to get a sense of what
  the reporting looks like.</p>
{:else}
  <br />
  <a href="{ pipeline }" target="_blank">CI Pipeline</a>
{/if}
<Summaries year={year} summaries={filteredSummaries} participants={participants} />
<PerDayGraph items={filteredSummaries} />
<CumulativeGraph items={filteredSummaries} />
<PercentRuntimeGraph items={filteredSummaries} />
