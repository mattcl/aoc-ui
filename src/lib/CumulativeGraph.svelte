<script lang="ts">
  import Plot from 'svelte-plotly.js';
  import type { Summary } from './common'

  export let items: Summary[] = [];
  export let days: number[] = [];

  let defaultColors = [
    '#72e5ef',
    '#11a0aa',
    '#0c4152',
    '#a8b8e6',
    '#4c319e',
    '#db77e6',
    '#6a74aa',
    '#b5e287',
    '#0b5313',
    '#42f18f',
    '#48950f',
    '#84ee15',
    '#652a0d',
    '#bd854a',
    '#eb1138',
    '#d85f2d',
    '#f6cf89',
    '#89975b',
    '#4e4809',
    '#f4d403',
    '#db6f8a',
    '#a113b2',
    '#7212ff',
    '#fd048f',
    '#9b1b5c'
  ];
  $: colorway = days.map((d) => defaultColors[d - 1]);

  $: sortedItems = items.toSorted((a, b) => a.participant.localeCompare(b.participant));
  $: data = makeData(sortedItems, days);

  function makeData(raw: Summary[], days: number[]) {
    let d = [];

    if (raw.length == 0) {
      return d;
    }

    let participants = raw.map((x) => `${x.participant} (${x.language})`);

    days.map((day) => {
      let dayData = dataForDay(raw, day);

      d.push({
        type: 'bar',
        name: `day ${day}`,
        x: [...participants],
        y: dayData,
      });
    });

    return d;
  }

  function dataForDay(raw: Summary[], day: number): number[] {
    return raw.map((x) => {
      let key = `day_${day}`;
      let val = x[key];
      return val === null ? 0 : val * 1000;
    });
  }
</script>


{#if data.length > 0}
  <h2>Total Accumulated Runtime</h2>
  <Plot
    {data}
    layout={{
      colorway: colorway,
      height: 900,
      yaxis: {
        title: {
          text: "Time (ms)"
        }
      },
      barmode: "stack"
    }}
    fillParent='width'
    debounce={250}
  />
{/if}
