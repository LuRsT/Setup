#!/usr/bin/env bash
# Claude Code status line: plan-usage bar + context-window bar.
# Reads the status-line JSON payload on stdin.

jq -r '
  def esc: ([27] | implode);
  def clamp: if . < 0 then 0 elif . > 100 then 100 else . end;
  def colour: if   . >= 85 then "31"
              elif . >= 60 then "33"
              else "32" end;
  def bar($p):
    ($p | clamp) as $v
    | (($v / 10) | round) as $n
    | ($v | colour) as $c
    | esc + "[" + $c + "m" + (if $n > 0   then ("#" * $n)        else "" end)
    + esc + "[90m"         + (if $n < 10  then ("." * (10 - $n)) else "" end)
    + esc + "[0m " + esc + "[" + $c + "m" + (($v | round | tostring) + "%") + esc + "[0m";
  def dim($s): esc + "[90m" + $s + esc + "[0m";

  (.rate_limits.five_hour.used_percentage)   as $h
  | (.rate_limits.seven_day.used_percentage) as $d
  | (.context_window.used_percentage)        as $c
  | (if   ($h == null and $d == null) then null
     elif ($d == null) or (($h != null) and ($h >= $d)) then {p: $h, w: "5h"}
     else {p: $d, w: "7d"} end) as $u
  | (if $u == null then dim("usage n/a")
     else dim("usage") + " " + bar($u.p) + " " + dim("(" + $u.w + ")") end)
  + "   "
  + (if $c == null then dim("ctx n/a")
     else dim("ctx") + "   " + bar($c) end)
'
