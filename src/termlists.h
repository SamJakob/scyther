#ifndef TERMLISTS
#define TERMLISTS

#include "terms.h"

struct termlist
{
  Term term;
  struct termlist *next;
  struct termlist *prev;
};

typedef struct termlist *Termlist;

void termlistsInit (void);
void termlistsDone (void);
Termlist termlistDuplicate (Termlist tl);
Termlist termlistShallow (Termlist tl);
void termlistDelete (Termlist tl);
void termlistDestroy (Termlist tl);
void termlistPrint (Termlist tl);
int inTermlist (Termlist tl, Term term);
int isTermlistEqual (Termlist tl1, Termlist tl2);
Termlist termlistAdd (Termlist tl, Term term);
Termlist termlistAppend (const Termlist tl, const Term term);
Termlist termlistConcat (Termlist tl1, Termlist tl2);
Termlist termlistDelTerm (Termlist tl);
Termlist termlistConjunct (Termlist tl1, Termlist tl2);
Termlist termlistConjunctType (Termlist tl1, Termlist tl2, int termtype);
Termlist termlistType (Termlist tl, int termtype);
Termlist termlistAddVariables (Termlist tl, Term t);
Termlist termlistAddRealVariables (Termlist tl, Term t);
Termlist termlistAddBasic (Termlist tl, Term t);
Termlist termlistAddBasics (Termlist tl, Termlist scan);
Termlist termlistMinusTerm (Termlist tl, Term t);
int termlistLength (Termlist tl);
Term inverseKey (Termlist inverses, Term key);
Term termLocal (const Term t, Termlist fromlist, Termlist tolist,
		const Termlist locals, const int runid);
Termlist termlistLocal (Termlist tl, const Termlist fromlist,
			const Termlist tolist, const Termlist locals,
			const int runid);
int termlistContained (const Termlist tlbig, Termlist tlsmall);
int validSubst (const int matchmode, const Term term);
Term termFunction (Termlist fromlist, Termlist tolist, Term tx);
Termlist termlistForward (Termlist tl);

#endif
