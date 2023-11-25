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
  import type { Summary } from './common'

  export let year: number;
  export let items: Summary[] = [];

  //$: items = summaries.map((x) => x);
  let sort: keyof Summary = "total"
  let sortDirection: LowerCase<keyof typeof sortValue> = 'ascending';

  function handleSort() {
    items.sort((a, b) => {
      const [aVal, bVal] = [a[sort], b[sort]][
        sortDirection === 'ascending' ? 'slice' : 'reverse'
      ]();
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
</script>

<h2>Overview</h2>

{#if items.length == 0}
  <p>no data yet</p>
{:else}
  <p>time in milliseconds<p>
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
          <Label>Participant</Label>
          <IconButton class="material-icons">arrow_upward</IconButton>
        </Cell>
        <Cell columnId="language">
          <Label>Lang</Label>
          <IconButton class="material-icons">arrow_upward</IconButton>
        </Cell>
        {#each {length: 25} as _, i}
          <Cell numeric columnId="day_{i + 1}">
            <IconButton class="material-icons">arrow_upward</IconButton>
            <Label>Day {i + 1}</Label>
          </Cell>
        {/each}
        <Cell numeric columnId="total" class="col-stick-right">
          <Label>Total</Label>
          <IconButton class="material-icons">arrow_upward</IconButton>
        </Cell>
      </Row>
    </Head>
    <Body>
      {#each items as item (item.participant)}
        <Row>
          <Cell class="col-stick-left">{ item.participant }</Cell>
          <Cell>{ item.language }</Cell>
          <Cell numeric>{ formatNum(item.day_1) }</Cell>
          <Cell numeric>{ formatNum(item.day_2) }</Cell>
          <Cell numeric>{ formatNum(item.day_3) }</Cell>
          <Cell numeric>{ formatNum(item.day_4) }</Cell>
          <Cell numeric>{ formatNum(item.day_5) }</Cell>
          <Cell numeric>{ formatNum(item.day_6) }</Cell>
          <Cell numeric>{ formatNum(item.day_7) }</Cell>
          <Cell numeric>{ formatNum(item.day_8) }</Cell>
          <Cell numeric>{ formatNum(item.day_9) }</Cell>
          <Cell numeric>{ formatNum(item.day_10) }</Cell>
          <Cell numeric>{ formatNum(item.day_11) }</Cell>
          <Cell numeric>{ formatNum(item.day_12) }</Cell>
          <Cell numeric>{ formatNum(item.day_13) }</Cell>
          <Cell numeric>{ formatNum(item.day_14) }</Cell>
          <Cell numeric>{ formatNum(item.day_15) }</Cell>
          <Cell numeric>{ formatNum(item.day_16) }</Cell>
          <Cell numeric>{ formatNum(item.day_17) }</Cell>
          <Cell numeric>{ formatNum(item.day_18) }</Cell>
          <Cell numeric>{ formatNum(item.day_19) }</Cell>
          <Cell numeric>{ formatNum(item.day_20) }</Cell>
          <Cell numeric>{ formatNum(item.day_21) }</Cell>
          <Cell numeric>{ formatNum(item.day_22) }</Cell>
          <Cell numeric>{ formatNum(item.day_23) }</Cell>
          <Cell numeric>{ formatNum(item.day_24) }</Cell>
          <Cell numeric>{ formatNum(item.day_25) }</Cell>
          <Cell numeric class="col-stick-right">{ formatNum(item.total) }</Cell>
        </Row>
      {/each}
    </Body>
  </DataTable>
</div>
{#if year == 2022}
<p>2022 is incomplete because it was run before the spec and new benchamrking
so it's missing some participants It is included here to get a sense of what
the reporting looks like.</p>
{/if}

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
