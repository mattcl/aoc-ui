<script lang="ts">
  import IconButton from '@smui/icon-button';
  import TopAppBar, { Row, Section, Title } from '@smui/top-app-bar';
  import Tab, { Label } from '@smui/tab';
  import TabBar from '@smui/tab-bar';
  import About from './lib/About.svelte'
  import EventYear from './lib/EventYear.svelte'
  import Participate from './lib/Participate.svelte'

  let active = '2023';
</script>

<head>
</head>

<main>
  <TopAppBar
    variant='static'
    color='secondary'
  >
    <Row>
      <Section>
        <Title>AOC Comparative Benchmarks</Title>
      </Section>
    </Row>
  </TopAppBar>
  <TabBar tabs={['2022', '2023', 'About', 'Participate']} let:tab bind:active>
    <Tab {tab} minWidth>
      <Label>{tab}</Label>
    </Tab>
  </TabBar>

  {#if active === '2022'}
    <EventYear year={2022} />
  {:else if active == '2023'}
    <EventYear year={2023} />
  {:else if active == 'About'}
    <About />
  {:else if active == 'Participate'}
    <Participate />
  {/if}
</main>
