<script lang="ts">
  // your script goes here
  let spec = 'https://github.com/mattcl/aoc-benchmarks/blob/master/SPECIFICATION.md';
  let templates = [
    {lang: 'python', url: 'https://github.com/mattcl/aoc-python-template'},
    {lang: 'rust', url: 'https://github.com/mattcl/aoc-template'},
  ];
</script>

<p>Firstly, I maintain this and the CI system/hardware on my own time as a fun
thing to do during a given AoC event. This is primarily something for my
friends and coworkers.</p>

<h3>Spec</h3>

<p>If you would like to particpate, submissions are required to conform to the
following specification: <a href="{spec}" target="_blank">{spec}</a>.</p>

<p>This makes it easier to wire up the steps and resources in the CI pipeline.
In previous years, adapting the pipeline to a bunch of inconsistent interfaces
was a not insignificant amount of effort.</p>

<p>Once a conforming project exists, message me to get it added to the
pipeline.</p>

<h3>Templates</h3>

<p>As mentioned in the specification, there are some templates for rust and
python projects that will conform to the specification. Templates for other
languages may be added later (contributions also welcome).</p>

<ul>
  {#each templates as template (template.lang) }
    <li><a href={template.url}>{template.lang}</li>
  {/each}
</ul>
