<script lang="ts">
  import Plot from 'svelte-plotly.js';
  import type { Summary } from './common'

  export let items: Summary[] = [];

  $: data = makeData(items);

  function makeData(raw: Summary[]) {
    let d = [];

    if (raw.length == 0) {
      return d;
    }

    let participants = items.map((x) => `${x.participant} (${x.language})`);


    for (let day = 1; day < 26; day++) {
      let dayData = dataForDay(raw, day);

      d.push({
        type: 'bar',
        name: `day ${day}`,
        x: [...participants],
        y: dayData,
      });
    }

    return d;
  }

  function dataForDay(raw: Summary[], day: number) {
    return raw.map((x) => {
      let total = x.total === null ? 0 : x.total;
      let key = `day_${day}`;
      let val = x[key];
      return val === null || total == 0 ? 0 : (val / total) * 100 ;
    });
  }
</script>


{#if data.length == 0 }

{:else}
  <h2>Percent of Overall Runtime</h2>
  <Plot
    {data}
    layout={{
      colorway: [
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
      ],
      height: 900,
      yaxis: {
        title: {
          text: "Percent"
        }
      },
      barmode: "stack"
    }}
    fillParent='width'
    debounce={250}
  />
{/if}
