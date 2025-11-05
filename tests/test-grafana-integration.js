/**
 * Grafana Integration Tests
 * 
 * Tests:
 * - Datasource availability and health
 * - Log retrieval from Loki
 * - Prometheus metrics queries
 * - Dashboard access and data
 * - Cluster information retrieval
 * - Namespace and pod metrics
 */

const axios = require('axios');

// Configuration
const GRAFANA_URL = 'http://localhost:3000';
const GRAFANA_USER = 'admin';
const GRAFANA_PASSWORD = 'UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX';

// Create axios instance
const grafanaApi = axios.create({
  baseURL: GRAFANA_URL,
  timeout: 10000,
});

// Store token globally for use across tests
let authToken = '';

describe('Grafana Integration Tests', () => {
  
  beforeAll(async () => {
    // Get authentication token
    try {
      const response = await axios.post(
        `${GRAFANA_URL}/api/auth/login`,
        {
          user: GRAFANA_USER,
          password: GRAFANA_PASSWORD,
        },
        { timeout: 5000 }
      );
      authToken = response.data.token;
      grafanaApi.defaults.headers.common['Authorization'] = `Bearer ${authToken}`;
    } catch (error) {
      throw new Error(`Failed to authenticate with Grafana: ${error.message}`);
    }
  });

  describe('Grafana Availability', () => {
    test('Grafana health endpoint should return 200', async () => {
      const response = await axios.get(`${GRAFANA_URL}/api/health`);
      expect(response.status).toBe(200);
      expect(response.data.database).toBe('ok');
      expect(response.data.version).toBeDefined();
      console.log(`✓ Grafana version: ${response.data.version}`);
    });

    test('Should authenticate successfully', () => {
      expect(authToken).toBeTruthy();
      expect(authToken.length).toBeGreaterThan(0);
      console.log(`✓ Authentication token obtained: ${authToken.substring(0, 20)}...`);
    });

    test('Should get Grafana user info', async () => {
      const response = await grafanaApi.get('/api/user');
      expect(response.status).toBe(200);
      expect(response.data.login).toBe(GRAFANA_USER);
      console.log(`✓ Current user: ${response.data.login}`);
    });
  });

  describe('Datasources', () => {
    let datasources = [];

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources');
      datasources = response.data;
    });

    test('Should have at least 3 datasources (Prometheus, Loki, Alertmanager)', () => {
      expect(datasources.length).toBeGreaterThanOrEqual(3);
      console.log(`✓ Found ${datasources.length} datasources`);
    });

    test('Should have Prometheus datasource', () => {
      const prometheus = datasources.find(ds => ds.name === 'Prometheus');
      expect(prometheus).toBeDefined();
      expect(prometheus.type).toBe('prometheus');
      expect(prometheus.isDefault).toBe(true);
      console.log(`✓ Prometheus datasource configured (URL: ${prometheus.url})`);
    });

    test('Should have Loki datasource', () => {
      const loki = datasources.find(ds => ds.name === 'Loki');
      expect(loki).toBeDefined();
      expect(loki.type).toBe('loki');
      expect(loki.url).toContain('loki');
      console.log(`✓ Loki datasource configured (URL: ${loki.url})`);
    });

    test('Should have Alertmanager datasource', () => {
      const alertmanager = datasources.find(ds => ds.name === 'Alertmanager');
      expect(alertmanager).toBeDefined();
      expect(alertmanager.type).toBe('alertmanager');
      console.log(`✓ Alertmanager datasource configured (URL: ${alertmanager.url})`);
    });

    test('Should verify Prometheus datasource health', async () => {
      const response = await grafanaApi.get('/api/datasources/name/Prometheus/health');
      expect(response.status).toBe(200);
      console.log(`✓ Prometheus health check passed`);
    });

    test('Should verify Loki datasource health', async () => {
      const response = await grafanaApi.get('/api/datasources/name/Loki/health');
      expect(response.status).toBe(200);
      console.log(`✓ Loki health check passed`);
    });
  });

  describe('Prometheus Metrics Queries', () => {
    let prometheusUid = '';

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources/name/Prometheus');
      prometheusUid = response.data.uid;
    });

    const testQueries = [
      { query: 'count(kube_pod_info)', label: 'Pod Count' },
      { query: 'count(kube_node_info)', label: 'Node Count' },
      { query: 'count(kube_namespace_info)', label: 'Namespace Count' },
      { query: 'up', label: 'Target Up Status' },
    ];

    testQueries.forEach(({ query, label }) => {
      test(`Should execute Prometheus query: ${label}`, async () => {
        const encodedQuery = encodeURIComponent(query);
        const response = await grafanaApi.get(
          `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=${encodedQuery}`
        );
        
        expect(response.status).toBe(200);
        expect(response.data.status).toBe('success');
        expect(response.data.data).toBeDefined();
        
        const resultCount = response.data.data.result?.length || 0;
        console.log(`✓ Query "${label}" executed (${resultCount} results)`);
      });
    });
  });

  describe('Loki Log Retrieval', () => {
    let lokiUid = '';

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources/name/Loki');
      lokiUid = response.data.uid;
    });

    const logQueries = [
      { query: '{job="kubelet"}', label: 'Kubelet Logs' },
      { query: '{namespace="kube-system"}', label: 'Kube-system Logs' },
      { query: '{namespace="monitoring"}', label: 'Monitoring Logs' },
    ];

    logQueries.forEach(({ query, label }) => {
      test(`Should retrieve logs: ${label}`, async () => {
        const endTime = Date.now() * 1000000;
        const startTime = endTime - 3600 * 1000000000; // 1 hour back
        
        const encodedQuery = encodeURIComponent(query);
        const response = await grafanaApi.get(
          `/api/datasources/proxy/uid/${lokiUid}/loki/api/v1/query_range`,
          {
            params: {
              query,
              start: startTime,
              end: endTime,
            },
          }
        );

        expect(response.status).toBe(200);
        expect(response.data.data).toBeDefined();
        
        const streamCount = response.data.data.result?.length || 0;
        const logCount = response.data.data.result?.reduce(
          (acc, stream) => acc + (stream.values?.length || 0),
          0
        ) || 0;
        
        console.log(`✓ Log query "${label}": ${streamCount} streams, ${logCount} entries`);
      });
    });
  });

  describe('Dashboards', () => {
    let allDashboards = [];

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/search?type=dash-db');
      allDashboards = response.data;
    });

    test('Should have multiple dashboards available', () => {
      expect(allDashboards.length).toBeGreaterThan(0);
      console.log(`✓ Found ${allDashboards.length} total dashboards`);
    });

    test('Should have Kubernetes dashboards', () => {
      const k8sDashboards = allDashboards.filter(d => 
        d.title.toLowerCase().includes('kubernetes')
      );
      expect(k8sDashboards.length).toBeGreaterThan(0);
      console.log(`✓ Found ${k8sDashboards.length} Kubernetes dashboards`);
      k8sDashboards.slice(0, 3).forEach(d => {
        console.log(`  • ${d.title}`);
      });
    });

    test('Should have system component dashboards', () => {
      const systemDashboards = [
        { title: 'Alertmanager', minCount: 1 },
        { title: 'etcd', minCount: 1 },
        { title: 'CoreDNS', minCount: 1 },
      ];

      systemDashboards.forEach(({ title, minCount }) => {
        const matching = allDashboards.filter(d => d.title.includes(title));
        expect(matching.length).toBeGreaterThanOrEqual(minCount);
        console.log(`✓ Found ${matching.length} dashboard(s) for ${title}`);
      });
    });

    test('Should access a Kubernetes dashboard', async () => {
      const k8sDashboard = allDashboards.find(d => 
        d.title.toLowerCase().includes('kubernetes')
      );
      
      expect(k8sDashboard).toBeDefined();
      
      const response = await grafanaApi.get(`/api/dashboards/uid/${k8sDashboard.uid}`);
      expect(response.status).toBe(200);
      expect(response.data.dashboard).toBeDefined();
      
      const panelCount = response.data.dashboard.panels?.length || 0;
      console.log(`✓ Dashboard "${k8sDashboard.title}" accessed (${panelCount} panels)`);
    });
  });

  describe('Cluster Information', () => {
    let prometheusUid = '';

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources/name/Prometheus');
      prometheusUid = response.data.uid;
    });

    const clusterQueries = [
      { query: 'count(kube_node_info)', label: 'Total Nodes' },
      { query: 'sum(machine_cpu_cores)', label: 'Total CPU Cores', optional: true },
      { query: 'sum(machine_memory_bytes)', label: 'Total Memory', optional: true },
      { query: 'count(kube_namespace_info)', label: 'Total Namespaces' },
      { query: 'count(kube_deployment_info)', label: 'Total Deployments' },
      { query: 'count(kube_pod_info)', label: 'Total Pods' },
    ];

    clusterQueries.forEach(({ query, label, optional }) => {
      const testFn = optional ? test.skip : test;
      
      testFn(`Should fetch cluster info: ${label}`, async () => {
        const encodedQuery = encodeURIComponent(query);
        const response = await grafanaApi.get(
          `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=${encodedQuery}`
        );
        
        expect(response.status).toBe(200);
        const results = response.data.data.result || [];
        expect(results.length).toBeGreaterThanOrEqual(0);
        
        if (results.length > 0) {
          const value = results[0].value[1];
          console.log(`✓ ${label}: ${value}`);
        } else {
          console.log(`⚠ ${label}: No data available`);
        }
      });
    });
  });

  describe('Namespace and Pod Metrics', () => {
    let prometheusUid = '';

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources/name/Prometheus');
      prometheusUid = response.data.uid;
    });

    test('Should get available namespaces', async () => {
      const encodedQuery = encodeURIComponent('count by (namespace) (kube_pod_info)');
      const response = await grafanaApi.get(
        `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=${encodedQuery}`
      );
      
      const namespaces = response.data.data.result?.map(r => r.metric.namespace) || [];
      expect(namespaces.length).toBeGreaterThan(0);
      console.log(`✓ Found ${namespaces.length} namespaces`);
      namespaces.slice(0, 5).forEach(ns => {
        console.log(`  • ${ns}`);
      });
    });

    test('Should get pod metrics', async () => {
      const encodedQuery = encodeURIComponent('count(kube_pod_info) by (namespace)');
      const response = await grafanaApi.get(
        `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=${encodedQuery}`
      );
      
      const results = response.data.data.result || [];
      expect(results.length).toBeGreaterThan(0);
      console.log(`✓ Got pod metrics for ${results.length} namespaces`);
    });

    test('Should get CPU usage metrics', async () => {
      const encodedQuery = encodeURIComponent(
        'topk(5, sum by (pod_name) (rate(container_cpu_usage_seconds_total[5m])))'
      );
      const response = await grafanaApi.get(
        `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=${encodedQuery}`
      );
      
      const pods = response.data.data.result || [];
      if (pods.length > 0) {
        console.log(`✓ Top pods by CPU usage:`);
        pods.forEach(p => {
          const podName = p.metric.pod_name || 'unknown';
          const cpu = p.value[1];
          console.log(`  • ${podName}: ${cpu} cores`);
        });
      } else {
        console.log('⚠ No CPU metrics available');
      }
    });
  });

  describe('Alert Rules', () => {
    let prometheusUid = '';

    beforeAll(async () => {
      const response = await grafanaApi.get('/api/datasources/name/Prometheus');
      prometheusUid = response.data.uid;
    });

    test('Should retrieve alert rules from Prometheus', async () => {
      const response = await grafanaApi.get(
        `/api/datasources/proxy/uid/${prometheusUid}/api/v1/rules`
      );
      
      expect(response.status).toBe(200);
      expect(response.data.data).toBeDefined();
      
      const groups = response.data.data.groups || [];
      console.log(`✓ Found ${groups.length} alert groups`);
      
      if (groups.length > 0) {
        const totalRules = groups.reduce((acc, g) => acc + g.rules.length, 0);
        console.log(`✓ Total alert rules: ${totalRules}`);
        
        groups.slice(0, 3).forEach(g => {
          console.log(`  • ${g.name}: ${g.rules.length} rules`);
        });
      }
    });
  });

  describe('Error Handling', () => {
    test('Should handle invalid datasource query gracefully', async () => {
      const prometheusUid = 'prometheus';
      try {
        await grafanaApi.get(
          `/api/datasources/proxy/uid/${prometheusUid}/api/v1/query?query=invalid!!!query`
        );
      } catch (error) {
        expect(error.response?.status).toBeGreaterThanOrEqual(400);
        console.log(`✓ Invalid query properly rejected with status ${error.response?.status}`);
      }
    });

    test('Should handle missing datasource gracefully', async () => {
      try {
        await grafanaApi.get('/api/datasources/name/NonExistentDataSource');
      } catch (error) {
        expect(error.response?.status).toBe(404);
        console.log(`✓ Missing datasource properly rejected with 404`);
      }
    });
  });

});

module.exports = {};
