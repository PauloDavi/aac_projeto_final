#include <bits/stdc++.h>
#include <curand.h>

using namespace std;

#define NUM_THREAD 512
#define N_RANDOMS 1000000
#define N_CITIES 26

std::string cities[N_CITIES] = {
  "joao_pessoa",
  "aracaju",
  "belem",
  "belo_horizonte",
  "boa_vista",
  "brasília",
  "campo_grande",
  "cuiaba",
  "curitiba",
  "florianopolis",
  "fortaleza",
  "goiania",
  "maceio",
  "manaus",
  "natal",
  "palmas",
  "porto_alegre",
  "porto_velho",
  "recife",
  "rio_branco",
  "rio_de_janeiro",
  "salvador",
  "sao_luis",
  "sao_paulo",
  "teresina",
  "vitoria"};

__device__ int distances[N_CITIES][N_CITIES] = {
  {0, 611, 2161, 2171, 6593, 2245, 3357, 3366, 3188, 3485, 688, 2442, 395, 5808, 185, 2253, 3889, 4822, 120, 5356, 2448, 949, 1660, 2770, 1224, 2001},
  {611, 0, 2079, 1578, 6000, 1652, 2765, 2775, 2595, 2892, 1183, 1848, 294, 5215, 788, 1662, 3296, 4230, 501, 4763, 1855, 356, 1578, 2187, 1142, 1408},
  {2161, 2079, 0, 2824, 6083, 2120, 2942, 2941, 3193, 3500, 1610, 2017, 2173, 5298, 2108, 1283, 3852, 4397, 2074, 4931, 3250, 2100, 806, 2933, 947, 3108},
  {2171, 1578, 2824, 0, 4736, 716, 1453, 1594, 1004, 1301, 2528, 906, 1854, 3951, 2348, 1690, 1712, 3050, 2061, 3584, 434, 1372, 2738, 586, 2302, 524},
  {6593, 6000, 6083, 4736, 0, 4275, 3836, 3142, 4821, 5128, 6548, 4076, 6279, 785, 6770, 4926, 5348, 1686, 6483, 2230, 5159, 5794, 6120, 4756, 6052, 5261},
  {2245, 1652, 2120, 716, 4275, 0, 1134, 1133, 1366, 1673, 2200, 209, 1930, 3490, 2422, 973, 2027, 2589, 2135, 3123, 1148, 1446, 2157, 1015, 1789, 1239},
  {3357, 2765, 2942, 1453, 3836, 1134, 0, 694, 991, 1298, 3407, 935, 3040, 3051, 3534, 1785, 1518, 2150, 3247, 2684, 1444, 2568, 2979, 1014, 2911, 1892},
  {3366, 2775, 2941, 1594, 3142, 1133, 694, 0, 1679, 1986, 3406, 934, 3049, 2357, 3543, 1784, 2206, 1456, 3255, 1990, 2017, 2566, 2978, 1614, 2910, 2119},
  {3188, 2595, 3193, 1004, 4821, 1366, 991, 1679, 0, 300, 3541, 1186, 2871, 4036, 3365, 2036, 711, 3135, 3078, 3669, 852, 2385, 3230, 408, 3143, 1300},
  {3485, 2892, 3500, 1301, 5128, 1673, 1298, 1986, 300, 0, 3838, 1493, 3168, 4443, 3662, 2336, 476, 3442, 3375, 3976, 1144, 2682, 3537, 705, 3450, 1597},
  {688, 1183, 1610, 2528, 6548, 2200, 3407, 3406, 3541, 3838, 0, 2482, 1075, 5763, 537, 2035, 4242, 4862, 800, 5396, 2805, 1389, 1070, 3127, 634, 2397},
  {2442, 1848, 2017, 906, 4076, 209, 935, 934, 1186, 1493, 2482, 0, 2125, 3291, 2618, 874, 1847, 2390, 2332, 2924, 1338, 1643, 2054, 926, 1986, 1428},
  {395, 294, 2173, 1854, 6279, 1930, 3040, 3049, 2871, 3168, 1075, 2125, 0, 5491, 572, 1851, 3572, 4505, 285, 5039, 2131, 632, 1672, 2453, 1236, 1684},
  {5808, 5215, 5298, 3951, 785, 3490, 3051, 2357, 4036, 4443, 5763, 3291, 5491, 0, 5985, 4141, 4563, 901, 5698, 1445, 4374, 5009, 5335, 3971, 5267, 4476},
  {185, 788, 2108, 2348, 6770, 2422, 3534, 3543, 3365, 3662, 537, 2618, 572, 5985, 0, 2345, 4066, 4998, 297, 5533, 2625, 1126, 1607, 2947, 1171, 2178},
  {2253, 1662, 1283, 1690, 4926, 973, 1785, 1784, 2036, 2336, 2035, 874, 1851, 4141, 2345, 0, 2747, 0, 2058, 3764, 2124, 1454, 1386, 1776, 1401, 2214},
  {3889, 3296, 3852, 1712, 5348, 2027, 1518, 2206, 711, 476, 4242, 1847, 3572, 4563, 4066, 2747, 0, 3662, 3779, 4196, 1553, 3090, 3891, 1109, 3804, 2001},
  {4822, 4230, 4397, 3050, 1686, 2589, 2150, 1456, 3135, 3442, 4862, 2390, 4505, 901, 4998, 0, 3662, 0, 4712, 544, 3473, 4023, 4434, 3070, 4366, 3575},
  {120, 501, 2074, 2061, 6483, 2135, 3247, 3255, 3078, 3375, 800, 2332, 285, 5698, 297, 2058, 3779, 4712, 0, 5243, 2338, 839, 1573, 2660, 1137, 1831},
  {5356, 4763, 4931, 3584, 2230, 3123, 2684, 1990, 3669, 3976, 5396, 2924, 5039, 1445, 5533, 3764, 4196, 544, 5243, 0, 4007, 4457, 4968, 3604, 4900, 4109},
  {2448, 1855, 3250, 434, 5159, 1148, 1444, 2017, 852, 1144, 2805, 1338, 2131, 4374, 2625, 2124, 1553, 3473, 2338, 4007, 0, 1649, 3015, 429, 2579, 521},
  {949, 356, 2100, 1372, 5794, 1446, 2568, 2566, 2385, 2682, 1389, 1643, 632, 5009, 1126, 1454, 3090, 4023, 839, 4457, 1649, 0, 1599, 1962, 1163, 1202},
  {1660, 1578, 806, 2738, 6120, 2157, 2979, 2978, 3230, 3537, 1070, 2054, 1672, 5335, 1607, 1386, 3891, 4434, 1573, 4968, 3015, 1599, 0, 2970, 446, 2607},
  {2770, 2187, 2933, 586, 4756, 1015, 1014, 1614, 408, 705, 3127, 926, 2453, 3971, 2947, 1776, 1109, 3070, 2660, 3604, 429, 1962, 2970, 0, 2792, 882},
  {1224, 1142, 947, 2302, 6052, 1789, 2911, 2910, 3143, 3450, 634, 1986, 1236, 5267, 1171, 1401, 3804, 4366, 1137, 4900, 2579, 1163, 446, 2792, 0, 2171},
  {2001, 1408, 3108, 524, 5261, 1239, 1892, 2119, 1300, 1597, 2397, 1428, 1684, 4476, 2178, 2214, 2001, 3575, 1831, 4109, 521, 1202, 2607, 882, 2171, 0}};

__device__ uint8_t rand_num(float *randoms, int index, int min = 1, int max = N_CITIES)
{
  index = index % N_RANDOMS;
  float random = randoms[index];
  return (uint8_t)(min + random * (max - min));
}

__device__ int calc_path_length(uint8_t *stops)
{
  int length = 0;
  for (int i = 0; i < N_CITIES; i++)
    length += distances[stops[i]][stops[i + 1]];
  return length;
}

string stops_to_path(uint8_t *stops)
{
  string path;
  for (int i = 0; i <= N_CITIES; i++)
  {
    path += cities[stops[i]];
    if (i < N_CITIES)
      path += " -> ";
  }
  return path;
}

__global__ void init_population(uint8_t *population, int *path_size, float *randoms, int pop_size)
{
  // Sequential thread index across the blocks
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx >= pop_size)
    return;
  auto index_stop = idx * (N_CITIES + 1);
  auto stops = population + index_stop;
  stops[0] = 0;
  for (int i = 1; i < N_CITIES; i++)
    stops[i] = i;
  for (int i = 1; i < N_CITIES - 1; i++) {
    auto n = rand_num(randoms, index_stop + i, i);
    if (n != i) {
      auto temp = stops[i];
      stops[i] = stops[n];
      stops[n] = temp;
    }
  }
  stops[N_CITIES] = 0;
  path_size[idx] = calc_path_length(stops);
}

__global__ void tsp_calc(uint8_t *population, int *path_size, int gen_thres, float *randoms, int pop_size)
{
  // Sequential thread index across the blocks
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx >= pop_size)
    return;
  auto stops = population + idx * (N_CITIES + 1);
  for (int gen = 1; gen <= gen_thres; gen++)
  {
    int rand_1 = rand_num(randoms, idx + gen * 2);
    int rand_2 = rand_num(randoms, idx + gen * 2 + 1);
    if (rand_1 == rand_2)
      continue;
    auto temp = stops[rand_1];
    stops[rand_1] = stops[rand_2];
    stops[rand_2] = temp;
    auto new_path_size = calc_path_length(stops);
    if (new_path_size <= path_size[idx])
      path_size[idx] = new_path_size;
    else
    {
      stops[rand_2] = stops[rand_1];
      stops[rand_1] = temp;
    }
  }
}

__global__ void minReduce(int *path_size, int pop_size, int *result_index)
{
  int ti = threadIdx.x;
  __shared__ volatile float min_value;
  __shared__ volatile float min_index;
  if (ti == 0) min_value = 999999;
  for (int i = ti; i < pop_size; i += NUM_THREAD)
  {
    if (i >= pop_size) break;
    float v = path_size[i];
    __syncthreads();
    while (v < min_value) {
      min_value = v;
      min_index = i;
    }
    __syncthreads();
  }
  if (ti == 0) result_index[0] = min_index;
}

// Main routine that executes on the host
int main(int argc, char *argv[])
{
  if (argc != 3)
  {
    cout << "Invalid args";
    return -1;
  }
  int gen_thres = atoi(argv[1]);
  int pop_size = atoi(argv[2]);

  uint8_t *population;
  int *path_size_gpu;
  float *randoms;
  auto mem_path_size = pop_size * sizeof(int);
  cudaMalloc((void **)&population, pop_size * (N_CITIES + 1));
  cudaMalloc((void **)&path_size_gpu, mem_path_size);
  cudaMalloc((void **)&randoms, N_RANDOMS * sizeof(float));

  curandGenerator_t gen;
  curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
  curandSetPseudoRandomGeneratorSeed(gen, time(NULL));
  curandGenerateUniform(gen, randoms, N_RANDOMS);

  auto num_blocks = ceil(float(pop_size) / NUM_THREAD);
  init_population<<<num_blocks, NUM_THREAD>>>(population, path_size_gpu, randoms, pop_size);
  tsp_calc<<<num_blocks, NUM_THREAD>>>(population, path_size_gpu, gen_thres, randoms, pop_size);

  int *best_index_gpu;
  int best_index = 0;
  cudaMalloc((void **)&best_index_gpu, sizeof(int));
  minReduce<<<1, NUM_THREAD>>>(path_size_gpu, pop_size, best_index_gpu);
  cudaMemcpy(&best_index, best_index_gpu, sizeof(int), cudaMemcpyDeviceToHost);

  int best_path_size = 0;
  uint8_t *best = (uint8_t *)malloc(N_CITIES + 1);
  cudaMemcpy(&best_path_size, path_size_gpu + best_index, sizeof(int), cudaMemcpyDeviceToHost);
  cudaMemcpy(best, population + best_index * (N_CITIES + 1), N_CITIES + 1, cudaMemcpyDeviceToHost);

  cout << "Best solution (" << best_path_size << " km"
       << "): "
       << stops_to_path(best) << endl;

  // Cleanup
  free(best);
  cudaFree(best_index_gpu);
  cudaFree(population);
  cudaFree(path_size_gpu);
  curandDestroyGenerator(gen);
  cudaFree(randoms);

  return 0;
}