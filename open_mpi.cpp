#include <bits/stdc++.h>
#include <mpi.h>

#include "data.hpp"

uint8_t rand_num(int min = 1, int max = n_cities) {
  return (uint8_t)(min + rand() % (max - min));
}

int calc_path_length(uint8_t *stops) {
  int length = 0;
  for (int i = 0; i < n_cities; i++)
    length += distances[stops[i]][stops[i + 1]];
  return length;
}

bool has_stop(uint8_t *stops, int n, uint8_t stop) {
  for (int i = 0; i < n; i++)
    if (stops[i] == stop)
      return true;
  return false;
}

string stops_to_path(uint8_t *stops) {
  string path;
  for (int i = 0; i <= n_cities; i++) {
    path += cities[stops[i]];
    if (i < n_cities)
      path += " -> ";
  }
  return path;
}

int main(int argc, char **argv) {
  if (argc != 4) {
    cout << "Invalid args";
    return -1;
  }

  int gen_thres = atoi(argv[1]);
  int pop_size = atoi(argv[2]);
  bool verbose = strcmp(argv[3], "true") == 0;

  srand(time(NULL));

  int world_rank, world_size;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  pop_size /= world_size;

  uint8_t population[pop_size][n_cities + 1];
  int path_size[pop_size];
  auto end_path_size = path_size + pop_size;

  for (int i = 0; i < pop_size; i++) {
    auto stops = population[i];
    stops[0] = 0;
    for (int i = 1; i < n_cities; i++)
      stops[i] = i;
    for (int i = 1; i < n_cities - 1; i++) {
      auto n = rand_num(i);
      if (n != i) {
        auto temp = stops[i];
        stops[i] = stops[n];
        stops[n] = temp;
      }
    }
    stops[n_cities] = 0;
    path_size[i] = calc_path_length(stops);
  }

  int best_size, best_index;
  for (int gen = 1; gen <= gen_thres; gen++) {
    for (int i = 0; i < pop_size; i++) {
      int rand_1 = rand_num();
      int rand_2;
      do {
        rand_2 = rand_num();
      } while (rand_1 == rand_2);
      auto stops = population[i];
      char temp = stops[rand_1];
      stops[rand_1] = stops[rand_2];
      stops[rand_2] = temp;
      auto new_path_size = calc_path_length(stops);
      if (new_path_size <= path_size[i])
        path_size[i] = new_path_size;
      else {
        stops[rand_2] = stops[rand_1];
        stops[rand_1] = temp;
      }
    }

    auto gen_best_size = *min_element(path_size, end_path_size);
    if (gen == 1 || gen_best_size < best_size) {
      best_size = gen_best_size;
      best_index = find(path_size, end_path_size, gen_best_size) - path_size;
    }
    if (verbose)
      cout << gen_best_size << endl;
  }

  if (world_rank == 0) {
    int size;
    uint8_t pop[n_cities + 1];

    for (int nprog = 1; nprog < world_size; nprog++) {
      MPI_Recv(&size, 1, MPI_INT, nprog, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Recv(&pop, n_cities + 1, MPI_INT8_T, nprog, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

      if (size < best_size) {
        best_size = size;
        population[best_index] = pop;
      }
    }

    cout << "Best solution (" << best_size << " km"
         << "): "
         << stops_to_path(population[best_index]) << endl;
  } else {
    MPI_Send(&best_size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
    MPI_Send(population[best_index], n_cities + 1, MPI_INT8_T, 0, 1, MPI_COMM_WORLD);
  }

  MPI_Finalize();
  return 0;
}