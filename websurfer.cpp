#include <iostream> 
#include <vector> 
#include <cmath> 
using namespace std; 
 
int main() { 
    int n; 
    cin >> n; 
 
    vector<vector<int>> A(n, vector<int>(n)); 
    for (int i = 0; i < n; i++) 
        for (int j = 0; j < n; j++) 
            cin >> A[i][j]; 
 
    double d = 0.85; 
    vector<double> rank(n, 1.0 / n), next(n); 
 
    for (int it = 0; it < 100; it++) { 
        fill(next.begin(), next.end(), (1.0 - d) / n); 
        double dead = 0; 
 
        for (int i = 0; i < n; i++) { 
            int out = 0; 
            for (int j = 0; j < n; j++) 
                out += A[i][j]; 
 
            if (out == 0) 
                dead += rank[i]; 
            else 
                for (int j = 0; j < n; j++) 
                    if (A[i][j]) 
                        next[j] += d * rank[i] / out; 
        } 
 
        for (int j = 0; j < n; j++) 
            next[j] += d * dead / n; 
 
        rank = next; 
    } 
 
    for (int i = 0; i < n; i++) 
        cout << "Page " << i + 1 << ": " << rank[i] << "\n"; 
 
    return 0; 
} 