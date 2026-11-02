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
 
    vector<double> hub(n, 1), auth(n, 1); 
 
    for (int it = 0; it < 100; it++) { 
        vector<double> newAuth(n, 0), newHub(n, 0); 
 
        for (int i = 0; i < n; i++) 
            for (int j = 0; j < n; j++) { 
                newAuth[j] += A[i][j] * hub[i]; 
                newHub[i] += A[i][j] * auth[j]; 
            } 
 
        double sum = 0; 
        for (double x : newAuth) sum += x * x; 
        sum = sqrt(sum); 
        if (sum > 0) 
            for (double &x : newAuth) x /= sum; 
 
        sum = 0; 
        for (double x : newHub) sum += x * x; 
        sum = sqrt(sum); 
        if (sum > 0) 
            for (double &x : newHub) x /= sum; 
 
        auth = newAuth; 
        hub = newHub; 
    } 
 
    cout << "Authority Scores:\n"; 
    for (int i = 0; i < n; i++) 
        cout << "Page " << i + 1 << ": " << auth[i] << "\n"; 
 
    cout << "\nHub Scores:\n"; 
    for (int i = 0; i < n; i++) 
        cout << "Page " << i + 1 << ": " << hub[i] << "\n"; 
return 0; 
}