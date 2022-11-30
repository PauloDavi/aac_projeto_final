#include <bits/stdc++.h>

#include "data.hpp"

using namespace std;

struct individual {
  string gnome;
  int path_size;
};

int rand_num(int start, int end) {
  int r = end - start;
  int rnum = start + rand() % r;
  return rnum;
}

bool has_char(string s, char ch) {
  for (auto c : s) {
    if (c == ch) return true;
  }
  return false;
}

string mutated_gene(string gnome) {
  while (true) {
    int rand_1 = rand_num(1, cities.size());
    int rand_2 = rand_num(1, cities.size());
    if (rand_2 != rand_1) {
      char temp = gnome[rand_1];
      gnome[rand_1] = gnome[rand_2];
      gnome[rand_2] = temp;
      break;
    }
  }
  return gnome;
}

string create_gnome() {
  string gnome = "0";
  while (true) {
    if (gnome.size() == cities.size()) {
      gnome += gnome[0];
      break;
    }

    int temp = rand_num(1, cities.size());

    if (!has_char(gnome, (char)(temp + 48))) {
      gnome += (char)(temp + 48);
    }
  }

  return gnome;
}

int calc_path_length(vector<vector<int>> distance_tab, string gnome) {
  int length = 0;

  for (int i = 0; i < gnome.size() - 1; i++) {
    length += distance_tab[gnome[i] - 48][gnome[i + 1] - 48];
  }

  return length;
}

int cooldown(int temp) {
  return (90 * temp) / 100;
}

bool compare_individual(struct individual t1, struct individual t2) {
  return t1.path_size < t2.path_size;
}

void print_table(int gen, int temperature, vector<struct individual> population) {
  cout << "Generation: " << gen << endl;
  cout << "Current temperature: " << temperature << endl;
  cout << "-----------------" << endl;
  cout << "|GNOME"
       << "\t| "
       << "SIZE\t|" << endl;
  cout << "-----------------" << endl;

  for (auto p : population) {
    cout << "|" << p.gnome << "\t| " << p.path_size << " km\t|" << endl;
  }
  cout << "-----------------" << endl
       << endl;
}

string gnome_to_path(string gnome) {
  string path;

  for (int i = 0; i < gnome.size(); i++) {
    path += cities[gnome[i] - 48];
    if (i != gnome.size() - 1) {
      path += " -> ";
    }
  }

  return path;
}

void tsp_calc(vector<vector<int>> distance_tab, int pop_size, int gen_thres, bool verbose) {
  vector<struct individual> population;
  struct individual temp;
  struct individual best;
  int temperature = 100000;

  for (int i = 0; i < pop_size; i++) {
    temp.gnome = create_gnome();
    temp.path_size = calc_path_length(distance_tab, temp.gnome);
    population.push_back(temp);
  }

  sort(population.begin(), population.end(), compare_individual);
  best = population[0];
  if (verbose) {
    print_table(0, temperature, population);
  }

  for (int gen = 1; gen <= gen_thres; gen++) {
    for (int i = 0; i < pop_size; i++) {
      struct individual p1 = population[i];

      while (true) {
        struct individual new_gnome;
        new_gnome.gnome = mutated_gene(p1.gnome);
        new_gnome.path_size = calc_path_length(distance_tab, new_gnome.gnome);

        if (new_gnome.path_size <= p1.path_size) {
          population[i] = new_gnome;
          break;
        } else {
          float prob = pow(2.7, double((p1.path_size - new_gnome.path_size) / temperature));
          if (prob > 0.5) {
            population[i] = new_gnome;
            break;
          }
        }
      }
    }

    temperature = cooldown(temperature);
    sort(population.begin(), population.end(), compare_individual);
    if (verbose) {
      print_table(0, temperature, population);
    }

    if (compare_individual(population[0], best)) {
      best = population[0];
    }
  }

  cout << "Best solution: " << endl;
  cout << "Path: " << gnome_to_path(best.gnome) << endl;
  cout << "Size: " << best.path_size << " km" << endl;
}

vector<vector<int>> create_distance_tab() {
  vector<vector<int>> distance_tab;

  for (auto startCity : cities) {
    vector<int> temp;

    for (auto endCity : cities) {
      string path = startCity + ":" + endCity;
      string reverse_path = endCity + ":" + startCity;

      if (distances.find(path) == distances.end()) {
        temp.push_back(distances[reverse_path]);
      } else {
        temp.push_back(distances[path]);
      }
    }

    distance_tab.push_back(temp);
  }

  return distance_tab;
}

int main(int argc, char** argv) {
  if (argc != 4) {
    cout << "Invalid args";
    return -1;
  }

  int gen_thres = atoi(argv[1]);
  int pop_size = atoi(argv[2]);
  bool verbose = strcmp(argv[3], "true") == 0;
  vector<vector<int>> distance_tab = create_distance_tab();

  tsp_calc(distance_tab, pop_size, gen_thres, verbose);

  return 0;
}