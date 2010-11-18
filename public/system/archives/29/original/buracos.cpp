#include <iostream>
#include <queue>
#include <vector>
#define MAX 3001

using namespace std;

class pilha {
   vector<int> p;
   int _top;

   public:
      pilha();
      void pop();
      int top();
      void push(int);
      bool empty();
      void clear();
};

pilha::pilha() {
   _top = -1;
}

void pilha::pop() {
   if (!empty())
      _top--;
}

int pilha::top() {
   return p[_top];
}

void pilha::push(int i) {
   _top++;
   if (p.size() < _top+1)
      p.push_back(i);
   else
      p[_top] = i;
}

bool pilha::empty() {
   return (_top == -1);
}

void pilha::clear() {
   _top = -1;
}

pilha Grafo[MAX];
pilha GrafoInv[MAX];

#define BRANCO    0
#define VERMELHO  1
#define PRETO     2

int busca(int max) {
   bool visitados[max+1];
   int i, n, nodo;
   queue<int> Q;

   for (i=1; i<=max; i++)
      visitados[i] = false;

   Q.push(1);
   while ( !Q.empty() ) {
      nodo = Q.front();
      Q.pop();
      visitados[nodo] = true;
      while ( !Grafo[nodo].empty() ) {
         n = Grafo[nodo].top();
         if ( !visitados[n] )
            Q.push( n );
         Grafo[nodo].pop();
      }
   }
   for (i=1; i<=max; i++)
      if (!visitados[i])
         return false;

   for (i=1; i<=max; i++)
      visitados[i] = false;

   Q.push(1);
   while ( !Q.empty() ) {
      nodo = Q.front();
      Q.pop();
      visitados[nodo] = true;
      while ( !GrafoInv[nodo].empty() ) {
         n = GrafoInv[nodo].top();
         if ( !visitados[n] )
            Q.push( n );
         GrafoInv[nodo].pop();
      }
   }
   for (i=1; i<=max; i++)
      if (!visitados[i])
         return false;

   return true;
}

int main () {
   int N=0, i, j, P, B, x, y;

   while (cin >> P >> B && P!=0) {

      for (i=1; i<=P; i++) {
         Grafo[i].clear();
         GrafoInv[i].clear();
      }
      for (i=0; i<B; i++) {
         cin >> x >> y;
         Grafo[x].push(y);
         GrafoInv[y].push(x);
      }
      cout << "Teste " << ++N << endl;
      cout << (busca(P)?"S\n":"N\n") << endl;
   }
}
