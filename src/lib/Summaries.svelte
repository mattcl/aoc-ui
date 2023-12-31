<script lang="ts">
  import { onMount, afterUpdate } from 'svelte';
  import DataTable, {
    Head,
    Body,
    Row,
    Cell,
    Label,
    SortValue,
  } from '@smui/data-table';
  import IconButton from '@smui/icon-button';
  import Tooltip, { Wrapper } from '@smui/tooltip';

  import type { Summary, Participant } from './common'

  export let year: number;
  export let summaries: Summary[] = [];
  export let participants: Participant[] = [];
  export let days: number[] = [];

  let tableElement;

  $: repoMap = makeRepoMap(participants);
  $: completedCount = makeCompletedMap(summaries, days);
  $: largestPerDay = getLargestPerDay(summaries, days);
  $: virtualTotals = makeVirtualTotals(summaries, days, largestPerDay);
  $: smallestPerDay = getSmallestPerDay(summaries, days);

  let items = [];
  $: {
    items = summaries.map((x) => x);
    handleSort();
  }

  let sort: keyof Summary = "total"
  let sortDirection: LowerCase<keyof typeof sortValue> = 'ascending';

  function computeTotal(summary: Summary, days: number[]): number {
    let t = 0;
    days.map((d) => {
        let key = `day_${d}`;
        if (summary[key] !== null) {
          t += summary[key];
        }
    });

    return t;
  }

  function getLargestPerDay(sumamries: Summary[], days: number[]) {
    let out = {};
    days.forEach(day => {
      let max = 0;
      summaries.forEach(summary => {
        const key = `day_${day}`;
        const val = summary[key];
        if (val !== null && val > max) {
          max = val;
        }
      });
      out[day] = max;
    });

    return out;
  }

  function getSmallestPerDay(sumamries: Summary[], days: number[]) {
    let out = {};
    days.forEach(day => {
      let min = 1000000; // this is higher than we would allow anyway
      summaries.forEach(summary => {
        const key = `day_${day}`;
        const val = summary[key];
        if (val !== null && val < min) {
          min = val;
        }
      });
      out[day] = min;
    });

    return out;
  }

  function makeVirtualTotals(sumamries: Summary[], days: number[], largestPerDay) {
    let out = {};

    summaries.forEach(summary => {
      let total = 0;
      let anyVirtual = false;
      days.forEach(day => {
        const key = `day_${day}`;
        const val = summary[key];
        if (val === null && day in largestPerDay) {
          total += largestPerDay[day] + 0.001;
          anyVirtual = true;
        } else {
          total += val;
        }
      });
      out[summary.participant] = {total: total, anyVirtual: anyVirtual};
    });

    return out;
  }

  let computedTotals = {};
  $: {
    computedTotals = makeComputedTotals(summaries, days);

    handleSort();
  };

  $: smallestTotal = getSmallestTotal(summaries, virtualTotals);

  function getSmallestTotal(summaries, virtualTotals) {
    let min = 1000000;
    summaries.forEach((x) => {
      let v = virtualTotals[x.participant].total;
      if (v < min) {
        min = v;
      }
    });

    return min;
  }

  function makeComputedTotals(summaries: Summary[], days: number[]) {
    let out = {};
    summaries.map((x) => {
      let v = computeTotal(x, days)
      out[x.participant] = v;
    });

    return out;
  };

  function getVal(summary: Summary, key: string) {
    if (key === 'total') {
      return virtualTotals[summary.participant]['total'];
    } else {
      return summary[key];
    }
  }

  function hasPenalty(summary: Summary) {
    return virtualTotals[summary.participant]['anyVirtual'];
  }

  function handleSort() {
    items.sort((a, b) => {
      let s = sort;

      let [aVal, bVal] = [getVal(a, s), getVal(b, s)][
        sortDirection === 'ascending' ? 'slice' : 'reverse'
      ]();

      // always sort alpha ascending on name to break ties for null values
      if (aVal === null && bVal ===null) {
        return getVal(a, 'participant').localeCompare(getVal(b, 'participant'));
      }

      // put the nulls as the 'end' of the list regardless of sort direction
      if (aVal === null) {
        return sortDirection === 'ascending' ? 1 : -1;
      }

      if (bVal === null) {
        return sortDirection === 'ascending' ? -1 : 1;
      }

      if (typeof aVal === 'string' && typeof bVal === 'string') {
        return aVal.localeCompare(bVal);
      }
      return Number(aVal) - Number(bVal);
    });
    items = [...items];

  }

  function formatNum(val: number | null): string {
    if (val === null) {
      return 'N/A';
    }
    // we get back time in seconds
    return (val * 1000).toFixed(3);
  }

  function makeRepoMap(participants: Participant[]) {
    let m = {};
    participants.map((x) => {m[x.name] = x.repo});
    return m;
  }

  function makeCompletedMap(summaries: Summary[], days: number[]) {
    let m = {};
    summaries.map((x) => {
      let count = 0;
      days.map((d) => {
        let key = `day_${d}`;
        if (x[key] !== null) {
          count += 1;
        }
      });
      m[x.participant] = count;
    });
    return m;
  }

  onMount(async () => {
    setTimeout(() => {
      const scrollElement = tableElement.querySelector('.mdc-data-table__table-container');
      scrollElement.scrollLeft = scrollElement.scrollWidth;
    }, 100);
  });
</script>

<h2>Overview</h2>

{#if items.length == 0}
  <p>no data yet</p>
{:else}
  <p>Benchmarks run with <a href="https://github.com/sharkdp/hyperfine"><code>hyperfine</code></a>, averaged across available inputs, and reflect the cold-start time to solve a given day, meaning they include executable/runtime startup, reading the input file from disk, and producing the solution.
  </p>
  <p>Reported times are in milliseconds, and the best time is <span class="fastest">highlighted.</span><p>
{/if}

<div class="summary-table" bind:this={tableElement}>
  <DataTable
    sortable
    bind:sort
    bind:sortDirection
    on:SMUIDataTable:sorted={handleSort}
    table$aria-label="{year} Overview"
    style="max-width: 100%;"
  >
    <Head>
      <Row>
        <Cell columnId="participant" class="col-stick-left">
          <Label>Participant / Language</Label>
          <IconButton class="material-icons">arrow_upward</IconButton>
        </Cell>
        {#each days as day}
          <Cell numeric columnId="day_{day}">
            <IconButton class="material-icons">arrow_upward</IconButton>
            <Label>Day {day}</Label>
          </Cell>
        {/each}
        <Cell numeric columnId="total" class="col-stick-right">
          <IconButton class="material-icons">arrow_upward</IconButton>
          <Label>Total*</Label>
        </Cell>
      </Row>
    </Head>
    <Body>
      {#each items as item (item.participant)}
        <Row>
          <Cell class="col-stick-left"><a href="{ repoMap[item.participant] }" target="_blank">{ item.participant }</a> / { item.language }</Cell>
          {#each days as day}
            {#if item[`day_${day}`] === null }
              <Cell numeric style="color: darkgrey;">{ formatNum(item[`day_${day}`]) }</Cell>
            {:else if item[`day_${day}`] == smallestPerDay[day] }
              <Cell numeric class="fastest">{ formatNum(item[`day_${day}`]) }</Cell>
            {:else}
              <Cell numeric>{ formatNum(item[`day_${day}`]) }</Cell>
            {/if}
          {/each}
          {#if hasPenalty(item) }
            <Wrapper>
              <Cell numeric class="col-stick-right" style="color: darkgrey;">{ formatNum(computedTotals[item.participant]) }</Cell>
              <Tooltip class="high-tooltip">Vrtual total: { formatNum(virtualTotals[item.participant]['total']) }</Tooltip>
            </Wrapper>
          {:else if computedTotals[item.participant] == smallestTotal }
            <Cell numeric class="col-stick-right fastest">{ formatNum(computedTotals[item.participant]) }</Cell>
          {:else}
            <Cell numeric class="col-stick-right other">{ formatNum(computedTotals[item.participant]) }</Cell>
          {/if}
        </Row>
      {/each}
    </Body>
  </DataTable>
</div>

<p>* Total sorting uses a virtual total. If a participant has not solved a
particular day, the <i>slowest</i> time for that day <i>plus one
millisecond</i> is added to their virtual total. This results in a better
estimate of overall performance ranking, while preferring participants who have
submitted solutions. As a result, actual totals may appear out of order. Totals
that are adjusted in their sort order because of this will be <span
style="color: darkgrey;">grayed out</span>, and their virtual total can be seen
by hovering over the actual total</p>

<style>
  .summary-table {
    overflow: hidden;
  }

  :global(.high-tooltip) {
    z-index: 2000;
  }

  :global(.fastest) {
    color: orangered;
    font-weight: 600;
  }

  .summary-table :global(.col-stick-left) {
    position: sticky;
    left: 0;
    z-index: 1000;
    background: var(--mdc-theme-surface, #fff);
    border-right-width: 1px;
    border-right-style: solid;
    border-right-radius: var(--mdc-shape-medium, 4px);
    border-right-color: rgba(0,0,0,.12);
  }

  .summary-table :global(.col-stick-right) {
    position: sticky;
    right: 0;
    z-index: 1000;
    background: var(--mdc-theme-surface, #fff);
    margin-right: 2px;
    border-left-width: 1px;
    border-left-style: solid;
    border-left-radius: var(--mdc-shape-medium, 4px);
    border-left-color: rgba(0,0,0,.12);
  }
</style>
