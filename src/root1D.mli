(* File: RootFinding.mli

   Copyright (C) 2007

   Christophe Troestler
   email: Christophe.Troestler@umh.ac.be
   WWW: http://math.umh.ac.be/an/software/

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 2.1 or
   later as published by the Free Software Foundation, with the special
   exception on linking described in the file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details. *)

(** 1D Root finding algorithms. *)

val brent : ?tol:float -> (float -> float) -> float -> float -> float
(** [brent f a b] returns an approximation [x] of a root of [f] in
    the interval [[a,b]] with accuracy [6. *. epsilon_float
    *. abs_float(x) +. tol].

    @raise Invalid_argument if [f(a) *. f(b) > 0.].

    @param tol desired length of the interval of uncertainty of the final
    result (must be [>= 0]).  Default: [sqrt epsilon_float].

    Ref.: Brent, R. (1973) Algorithms for Minimization without
    Derivatives. Englewood Cliffs, NJ: Prentice-Hall.  *)

val bisection : ?good_enough:(float -> float -> float -> float -> bool) ->
                (float -> float) -> float -> float -> float
(** [bisection f a b] find an approximation of a root in the
    interval [[a,b]] using the bisection algorithm.

    @raise Invalid_argument if [f(a) *. f(b) > 0.].

    @param good_enough is a function taking as arguments the current
    [a], [b], [f(a)] and [f(b)] and returning whether they define a
    good enough approximation. *)

val newton : ?good_enough:(float -> float -> float -> bool) ->
  (float -> float * float) -> float -> float
(** [newton f_f' x0] returns an approximate root of [f] close to the
    initial guess [x0] using Newton's method.  [f_f'] is a function
    such that [f_f' x] returns the couple [(f x, f' x)] where [f' x]
    is the derivative of [f] at [x].

    @raise Failure if the derivative vanishes during the
    computations.

    @param good_enough takes as arguments the current approximation
    [x], the previous approximation [xprev], and [f(x)] and returns
    whether [x] is a good enough approximation. Default:
    [abs_float(f x) < sqrt epsilon_float].*)

val brent2 : ?tol:float -> (float -> float * int) -> float -> float -> float
(** [brent2 f a b] finds a zero of the function [f] in the same way
    [brent f a b] does except that [f x] returns the couple [(y, z)]
    for the number [y * 2**z].  Thus underflow and overflow can be
    avoided for a function with large range.

    Ref.: Brent, R. (1973) Algorithms for Minimization without
    Derivatives. Englewood Cliffs, NJ: Prentice-Hall. *)

(*
val secant : ?good_enough:(float -> float -> bool) ->
             (float -> float) -> float -> float -> float

val false_position : ?good_enough:(float -> float -> float -> float -> bool) ->
                     (float -> float) -> float -> float -> float

val muller : (float -> float) -> float -> float -> float
  (** http://en.wikipedia.org/wiki/M%C3%BCller%27s_method *)

 *)
;;
