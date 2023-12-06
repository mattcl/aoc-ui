<script lang="ts">
  import DataTable, {
    Head,
    Body,
    Row,
    Cell,
    Label,
    SortValue,
  } from '@smui/data-table';
  import IconButton from '@smui/icon-button';
  import type { Summary, Participant } from './common'

  export let year: number;
  export let summaries: Summary[] = [];
  export let participants: Participant[] = [];
  export let days: number[] = [];

  $: repoMap = makeRepoMap(participants);
  $: completedCount = makeCompletedMap(summaries, days);
  $: largestPerDay = getLargestPerDay(summaries, days);
  $: virtualTotals = makeVirtualTotals(summaries, days, largestPerDay);

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

  function makeComputedTotals(summaries: Summary[], days: number[]) {
    let out = {};
    summaries.map((x) => {
      out[x.participant] = computeTotal(x, days)
    });
    return out;
  };

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

  function makeVirtualTotals(sumamries: Summary[], days: number[], largestPerDay) {
    let out = {};

    summaries.forEach(summary => {
      let total = 0;
      days.forEach(day => {
        const key = `day_${day}`;
        const val = summary[key];
        if (val === null && day in largestPerDay) {
          total += largestPerDay[day];
        } else {
          total += val;
        }
      });
      out[summary.participant] = total;
    });

    return out;
  }

  let computedTotals = {};
  $: {
    computedTotals = makeComputedTotals(summaries, days);
    handleSort();
  };

  function getVal(summary: Summary, key: string) {
    if (key === 'total') {
      return virtualTotals[summary.participant];
    } else {
      return summary[key];
    }
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
</script>

<h2>Overview</h2>

{#if items.length == 0}
  <p>no data yet</p>
{:else}
  <p>times are in milliseconds<p>
{/if}

<div class="summary-table">
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
          <Label>Participant (completed)</Label>
          <IconButton class="material-icons">arrow_upward</IconButton>
        </Cell>
        <Cell columnId="language">
          <Label>Lang</Label>
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
          <Cell class="col-stick-left"><a href="{ repoMap[item.participant] }" target="_blank">{ item.participant }</a> ({ completedCount[item.participant] }/{ days.length })</Cell>
          <Cell>{ item.language }</Cell>
          {#each days as day}
            {#if item[`day_${day}`] === null }
              <Cell numeric style="color: darkgrey;">{ formatNum(item[`day_${day}`]) }</Cell>
            {:else}
              <Cell numeric>{ formatNum(item[`day_${day}`]) }</Cell>
            {/if}
          {/each}
          <Cell numeric class="col-stick-right">{ formatNum(computedTotals[item.participant]) }</Cell>
        </Row>
      {/each}
    </Body>
  </DataTable>
</div>

<p>* Total sorting uses a virtual total computed using a penalty of the slowest
time for a given day, which is added to a participant's virtual total for days
that the participant has not implemented a solution. This results in a better
estimate of overall performance ranking when sorting by total, even if the
actual total numbers appear out of order.</p>

<style>
  .summary-table {
    overflow: hidden;
  }

  .summary-table :global(.col-stick-left) {
    position: sticky;
    left: 0;
    z-index: 9999;
    background: var(--mdc-theme-surface, #fff);
    border-right-width: 1px;
    border-right-style: solid;
    border-right-radius: var(--mdc-shape-medium, 4px);
    border-right-color: rgba(0,0,0,.12);
  }

  .summary-table :global(.col-stick-right) {
    position: sticky;
    right: 0;
    z-index: 9999;
    background: var(--mdc-theme-surface, #fff);
    margin-right: 2px;
    border-left-width: 1px;
    border-left-style: solid;
    border-left-radius: var(--mdc-shape-medium, 4px);
    border-left-color: rgba(0,0,0,.12);
  }
</style>
