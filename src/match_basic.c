#include <stdlib.h>
#include <stdio.h>
#include "memory.h"
#include "substitutions.h"
#include "runs.h"
#include "modelchecker.h"
#include "match_basic.h"

Termlist
candidates (const Knowledge know)
{
  Termlist knowset;
  Termlist candlist;

  /* candidates for typeless basic stuff */
  knowset = knowledgeSet (know);
  candlist = termlistAddBasics (NULL, knowset);
  termlistDelete (knowset);
  return candlist;
}


struct fvpass
{
  int (*solution) (struct fvpass, Knowledge);

  System sys;
  int run;
  Roledef roledef;
  int (*proceed) (System, int);
};

/*
 * fix variables in a message, and check whether it can be accepted.
 *
 * fp.sys is only accessed for the matching type.
 */


int
fixVariablelist (const struct fvpass fp, const Knowledge know,
		 Termlist varlist, const Term message)
{
  int flag = 0;

  Termlist tlscan;
  Termlist candlist;

  if (varlist != NULL)
    {
      if (!isTermVariable (varlist->term))
	{
	  while (varlist != NULL && !isTermVariable (varlist->term))
	    {
	      varlist = varlist->next;
	    }
	}
    }

  /* cond: varlist == NULL || isTermvariable(varlist->term) */

  if (varlist == NULL)
    {
      /* there are no (more) variables to be fixed. */
      /* actually trigger it if possible */

      int copied;
      Knowledge tempknow;

      /* first we propagate the substitutions in the knowledge */
      /* TODO this must also be done for all agent knowledge!! */

      if (knowledgeSubstNeeded (know))
	{
	  copied = 1;
	  tempknow = knowledgeSubstDo (know);
	}
      else
	{
	  copied = 0;
	  tempknow = know;
	}

      if (inKnowledge (tempknow, message))
	{
	  if (fp.solution != NULL)
	    {
	      flag = fp.solution (fp, tempknow);
	    }
	  else
	    {
	      flag = 1;
	    }
	}
      else
	flag = 0;

      /* restore state */
      if (copied)
	{
	  knowledgeDelete (tempknow);
	  knowledgeSubstUndo (know);
	}
      return flag;
    }

  /* cond: isTermvariable(varlist->term) */
  varlist->term = deVar (varlist->term);
  /* cond: realTermvariable(varlist->term) */
  candlist = candidates (know);
#ifdef DEBUG
  if (DEBUGL (5))
    {
      indent ();
      printf ("Set ");
      termPrint (varlist->term);
      printf (" with type ");
      termlistPrint (varlist->term->stype);
      printf (" from candidates ");
      termlistPrint (candlist);
      printf ("\n");
    }
#endif

  /* Now check all candidates. Do they work as candidates? */
  tlscan = candlist;
  while (tlscan != NULL && !(flag && fp.solution == NULL))
    {
      if (!isTermEqual (varlist->term, tlscan->term))
	{
	  /* substitute */
	  varlist->term->subst = tlscan->term;
	  if (validSubst (fp.sys->match, varlist->term))
	    {
#ifdef DEBUG
	      if (DEBUGL (5))
		{
		  indent ();
		  printf ("Substituting ");
		  termPrint (varlist->term);
		  printf ("\n");
		}
#endif
	      /* now we may need to substitute more */
	      flag = fixVariablelist (fp, know, varlist->next, message)
		|| flag;
	    }
	}
      tlscan = tlscan->next;
    }
  /* restore state: variable is not instantiated. */
  varlist->term->subst = NULL;

  /* garbage collect */
  termlistDelete (candlist);

  return flag;
}

/*
 * check whether a roledef, given some newer knowledge substitutions, can survive
 */

#define enabled_basic(sys,know,newterm) !inKnowledge(know,newterm)

/*
 * matchRead
 *
 * try to execute a read event. It must be able to be construct it from the
 * current intruder knowledge (Inject), but not from the forbidden knowledge
 * set, which we tried earlier.
 *
 * returns 0 if it is not enabled, 1 if it was enabled (and routes explored)
 */

int
matchRead_basic (const System sys, const int run,
		 int (*proceed) (System, int))
{
  Roledef rd;
  int flag = 0;
  struct fvpass fp;

  int solution (struct fvpass fp, Knowledge know)
  {
    Knowledge oldknow;
    Term newterm;

    /* remove variable linkages */
    newterm = termDuplicateUV (fp.roledef->message);
    /* a candidate, but if this is a t4 traversal, is it also an old one? */
    if (fp.sys->traverse < 4 ||
	fp.roledef->forbidden == NULL ||
	enabled_basic (fp.sys, fp.roledef->forbidden, newterm))
      {
	/* it is enabled, i.e. not forbidden */
	oldknow = fp.sys->know;
	fp.sys->know = know;
#ifdef DEBUG
	if (DEBUGL (5))
	  {
	    printf ("+");
	  }
#endif
	fp.proceed (fp.sys, fp.run);
	fp.sys->know = oldknow;
	termDelete (newterm);
	return 1;
      }
    else
      {
	/* blocked */
#ifdef DEBUG
	if (DEBUGL (5))
	  {
	    printf ("-");
	  }
#endif
	termDelete (newterm);
	return 0;
      }
  }

  rd = runPointerGet (sys, run);
  Termlist varlist = termlistAddVariables (NULL, rd->message);

  fp.sys = sys;
  fp.run = run;
  fp.roledef = rd;
  fp.proceed = proceed;
  fp.solution = solution;

#ifdef DEBUG
  if (DEBUGL (5))
    {
      indent ();
      printf ("{\n");
    }
#endif
  flag = fixVariablelist (fp, sys->know, varlist, rd->message);
  termlistDelete (varlist);
#ifdef DEBUG
  if (DEBUGL (5))
    {
      indent ();
      printf ("} with flag %i\n", flag);
    }
#endif
  return flag;
}

/* 
 * block
 *
 * Skips over an event. Because the intruder knowledge is incremental, we can
 * just overwrite the old value of forbidden.
 */

int
block_basic (const System sys, const int run)
{
  Knowledge pushKnow;
  Roledef rd;

  rd = runPointerGet (sys, run);
  pushKnow = rd->forbidden;
  rd->forbidden = sys->know;
  traverse (sys);
  rd->forbidden = pushKnow;
  return 1;
}

int
send_basic (const System sys, const int run)
{
  Roledef rd = runPointerGet (sys, run);
  /* execute send, push knowledge? */
  if (inKnowledge (sys->know, rd->message))
    {
      /* no new knowledge, so this remains */
      explorify (sys, run);
    }
  else
    {
      /* new knowledge, must store old state */
      Knowledge oldknow = sys->know;
      sys->know = knowledgeDuplicate (sys->know);

      sys->knowPhase++;
      knowledgeAddTerm (sys->know, rd->message);
      explorify (sys, run);
      sys->knowPhase--;

      knowledgeDelete (sys->know);
      sys->know = oldknow;
    }
  return 1;
}