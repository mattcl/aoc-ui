<script lang="ts">
  import type { Summary } from './common';
  import Plot from 'svelte-plotly.js';
  import Radio from '@smui/radio';
  import FormField from '@smui/form-field';

  export let items: Summary[] = [];
  export let days: number[] = [];

  let defaultColors = ["#5ebf72", "#3f6f94", "#70b1ea", "#9d42b7", "#ea85f5", "#805d94", "#c39dd9", "#2d70f0", "#1abdc5", "#41763f", "#f85582", "#f6932e"];


  let scaleOptions = ['linear', 'log'];
  let scale = 'linear';

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

{#if data.length > 0}
  <h2>Runtime by Day</h2>
  <div>
    <span>Scale:</span>
    {#each scaleOptions as option }
      <FormField>
        <Radio bind:group={scale} value={option} />
        <span slot="label">{option}</span>
      </FormField>
    {/each}
  </div>
  <Plot
    {data}
    layout={{
      colorway: defaultColors,
      height: 500,
      yaxis: {
        title: {
          text: "Time (ms)"
        },
        type: scale
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
