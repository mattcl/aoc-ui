<script lang="ts">
  import type { Summary, Participant } from './common';
  import Summaries from './Summaries.svelte';
  import CumulativeGraph from './CumulativeGraph.svelte';
  import PercentRuntimeGraph from './PercentRuntimeGraph.svelte';
  import PerDayGraph from './PerDayGraph.svelte';
  import Checkbox from '@smui/checkbox';
  import FormField from '@smui/form-field';
  import Accordion, { Panel, Header, Content } from '@smui-extra/accordion';
  import Button from '@smui/button';

  let base_url = import.meta.env.VITE_API_BASE;

  export let year: number;

  let summaries: Summary[] = [];
  let participants: Participant[] = [];
  let num_days = if (year == 2025) { 12 } else { 25 };
  let daysSel = new Array(num_days).fill(null).map((_, i) => i + 1);
  let daysFilters = makeDayFilterChunks(daysSel);

  function makeDayFilterChunks(days: number[]) {
    let chunks = new Array(Math.floor(days.length / 10) + 1).fill(null).map((_) => []);

    days.map((d, i) => {
      let idx = Math.floor(i / 10);
      chunks[idx].push({ name: d, disabled: false});
    });

    return chunks;
  }

  $: partFilters = participants.map((x) => {
    return { name: x.name, disabled: false };
  });
  let partSel = [];

  let uniqueLanguages = [];
  $: {
    uniqueLanguages = [...new Set(participants.map(x => x.language))].toSorted((a, b) => a.localeCompare(b));
  }

  let langSel = [];

  $: langFilters = uniqueLanguages.map((x) => {
    return { name: x, disabled: false };
  });

  function setPartAll(state) {
    if (state == true) {
      partSel = summaries.map((x) => x.participant);
    } else {
      partSel = [];
    }
  };

  function setLangAll(state) {
    if (state == true) {
      langSel = [...uniqueLanguages];
    } else {
      langSel = [];
    }
  };

  function setDayAll(state) {
    if (state == true) {
      daysSel = new Array(num_days).fill(null).map((_, i) => i + 1);
    } else {
      daysSel = [];
    }
  };

  function setDayAvailable(summaries: Summary[], all: bool = false) {
    let vals = [];
    for (let i = 1; i < num_days + 1; i++) {
      let key = `day_${i}`;

      if (all) {
        let all_have = true;
        for (let s = 0; s < summaries.length; s++) {
          if (summaries[s][key] === null) {
            all_have = false;
            break;
          }
        }
        if (all_have) {
          vals.push(i);
        }
      } else {
        for (let s = 0; s < summaries.length; s++) {
          if (summaries[s][key] != null) {
            vals.push(i);
            break;
          }
        }
      }
    }

    // always show at least one day
    if (vals.length == 0) {
      vals = [1];
    }

    daysSel = vals;
  }

  fetch(`${base_url}/api/v1/summaries?year=${year}`)
    .then((response) => response.json())
    .then((json) => (summaries = json))
    .then(() => {
        if (summaries.length > 0) {
          setDayAvailable(summaries);
        }
    });

  fetch(`${base_url}/api/v1/participants?year=${year}`)
    .then((response) => response.json())
    .then((json) => (participants = json))
    .then(() => {
      // this is a hack to exclude some very large runtimes from showing by
      // default for 2022 only
      partSel = participants.filter((x) => year > 2022 || x.name != 'pting').map((x) => x.name);
      langSel = [...new Set(participants.map(x => x.language))].toSorted((a, b) => a.localeCompare(b));

    });

  $: filteredSummaries = summaries.filter((item) => partSel.includes(item.participant) && langSel.includes(item.language));

  $: sortedDays = daysSel.toSorted((a, b) => a - b);

  let pipeline = `http://ci.papercode.net:8080/teams/main/pipelines/aoc${year}`

</script>

<div>
  <Accordion multiple>
    <Panel>
      <Header>Participant filters</Header>
      <Content>
        <div>
          Select
          <Button on:click={() => setPartAll(true)}>all</Button>
          <Button on:click={() => setPartAll(false)}>none</Button>
        </div>
        <div>
          {#each partFilters as option}
            <FormField>
              <Checkbox bind:group={partSel} value={option.name} disabled={option.disabled} />
              <span slot="label">{option.name}</span>
            </FormField>
          {/each}
        </div>
      </Content>
    </Panel>
    <Panel>
      <Header>Language filters</Header>
      <Content>
        <div>
          Select
          <Button on:click={() => setLangAll(true)}>all</Button>
          <Button on:click={() => setLangAll(false)}>none</Button>
        </div>
        <div>
          {#each langFilters as option}
            <FormField>
              <Checkbox bind:group={langSel} value={option.name} disabled={option.disabled} />
              <span slot="label">{option.name}</span>
            </FormField>
          {/each}
        </div>
      </Content>
    </Panel>
    <Panel>
      <Header>Day filters</Header>
      <Content>
        <div>
          Select
          <Button on:click={() => setDayAll(true)}>all</Button>
          <Button on:click={() => setDayAll(false)}>none</Button>
          <Button on:click={() => setDayAvailable(filteredSummaries)}>any participant solved</Button>
          <Button on:click={() => setDayAvailable(filteredSummaries, true)}>all participants solved</Button>
        </div>
        {#each daysFilters as chunk}
          <div>
            {#each chunk as option}
              <FormField style="width: 75px;">
                <Checkbox bind:group={daysSel} value={option.name} disabled={option.disabled} />
                <span slot="label">{option.name}</span>
              </FormField>
            {/each}
          </div>
        {/each}
      </Content>
    </Panel>
  </Accordion>
</div>

{#if year == 2022}
  <p>2022 is incomplete because it was run before the spec and new benchmarking,
  so it's missing some participants. It is included here to get a sense of what
  the reporting looks like.</p>
{:else}
  <br />
  <a href="{ pipeline }" target="_blank">CI Pipeline</a>
{/if}
<Summaries year={year} days={sortedDays} summaries={filteredSummaries} participants={participants} />
<PerDayGraph days={sortedDays} items={filteredSummaries} />
<CumulativeGraph days={sortedDays} items={filteredSummaries} />
<PercentRuntimeGraph days={sortedDays} items={filteredSummaries} />
