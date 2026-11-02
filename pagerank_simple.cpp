 
#include <iostream> 
#include <vector> 
#include <cmath> 
using namespace std; 
 
int main() { 
    int n; 
    cout << "Enter number of pages: "; 
    cin >> n; 
 
    vector<vector<int>> A(n, vector<int>(n)); 
    cout << "Enter adjacency matrix:\n"; 
 
    for (int i = 0; i < n; i++) 
        for (int j = 0; j < n; j++) 
            cin >> A[i][j]; 
 
    vector<double> rank(n, 1.0 / n), next(n); 
    int iterations = 0; 
 
    while (true) { 
        fill(next.begin(), next.end(), 0.0); 
 
        for (int i = 0; i < n; i++) { 
            int out = 0; 
            for (int j = 0; j < n; j++) 
                out += A[i][j]; 
 
            if (out > 0) 
                for (int j = 0; j < n; j++) 
                    if (A[i][j]) 
                        next[j] += rank[i] / out; 
        } 
 
        iterations++; 
        bool converged = true; 
 
        for (int i = 0; i < n; i++) 
            if (abs(next[i] - rank[i]) > 1e-6) 
                converged = false; 
 
        rank = next; 
        if (converged || iterations >= 1000) break; 
    } 
 
    cout << "\nPageRank:\n"; 
    for (int i = 0; i < n; i++) 
        cout << "Page " << i + 1 << ": " << rank[i] << "\n"; 
 
    cout << "Iterations: " << iterations << "\n"; 
    return 0; 
}