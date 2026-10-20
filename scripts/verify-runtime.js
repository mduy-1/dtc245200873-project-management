// Run: Get-Content -Raw scripts/verify-runtime.js | docker compose exec -T app node
(async()=>{
  const metrics=await (await fetch('http://cadvisor:8080/metrics')).text();
  const containers=metrics.split('\n').filter(x=>x.startsWith('container_memory_working_set_bytes{') && /image="[^"]+"/.test(x));
  console.log('Container memory series:',containers.length);
  if(!containers.length)throw Error('No per-container metrics');
  for(const query of ['{service="app"}','{service="nginx"}','sum by (service) (count_over_time({job="project-management"}[5m]))']){
    const url='http://loki:3100/loki/api/v1/query_range?query='+encodeURIComponent(query)+'&limit=2';
    const response=await fetch(url);const data=await response.json();
    if(!response.ok||data.status!=='success'||!data.data.result.length)throw Error('Loki query failed: '+query);
    console.log('LogQL PASS:',query,'results:',data.data.result.length);
  }
})().catch(e=>{console.error(e.message);process.exit(1);});
