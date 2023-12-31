<script lang="ts">
  import type { Summary } from './common';
  import Plot from 'svelte-plotly.js';
  import Radio from '@smui/radio';
  import FormField from '@smui/form-field';

  export let items: Summary[] = [];
  export let days: number[] = [];

  // let defaultColors = ["#21f0b6", "#8c3ba0", "#2c97e0", "#a3553a", "#d595d9", "#2b5013", "#fca552", "#fe5360", "#bfd6fa", "#c4ce50", "#598d83", "#73f02e"];
  let defaultColors = ["#41bbc5", "#aa8c5c", "#943112", "#7990c5", "#9ad859", "#9b4c9d", "#e81659", "#fa7922", "#6e8e3b", "#fec9af", "#55450a", "#e3a0fa"];


  let scaleOptions = ['linear', 'log'];
  let scale = 'linear';

  $: sortedItems = items.toSorted((a, b) => a.participant.localeCompare(b.participant));
  $: data = makeData(sortedItems, days);

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
      height: 700,
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
