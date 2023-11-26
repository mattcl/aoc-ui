<script lang="ts">
  import Plot from 'svelte-plotly.js';
  import type { Summary } from './common'

  export let items: Summary[] = [];
  export let days: number[] = [];

  $: data = makeData(items, days);

  function makeData(raw: Summary[], days: number[]) {
    let d = [];

    if (raw.length == 0) {
      return d;
    }

    raw.map((summary) => {
      d.push({
        x: days,
        y: dataForDays(summary, days),
        name: summary.participant,
        type: 'bar',
      })
    });

    return d;
  }

  function dataForDays(summary: Summary, days) {
    return days.map((x) => {
      let key = `day_${x}`;
      let val = summary[key];
      return val === null ? 0 : val * 1000;
    });
  }
</script>


{#if data.length == 0 }

{:else}
  <h2>Runtime by Day</h2>
  <Plot
    {data}
    layout={{
      height: 500,
      yaxis: {
        title: {
          text: "Time (ms)"
        }
      },
      xaxis: {
        title: {
          text: "Day"
        }
      },
      barmode: "group"
    }}
    fillParent='width'
    debounce={250}
  />
{/if}
