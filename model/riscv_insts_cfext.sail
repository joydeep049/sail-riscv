/*=======================================================================================*/
/*  RISCV Sail Model                                                                     */
/*                                                                                       */
/*  This Sail RISC-V architecture model, comprising all files and                        */
/*  directories except for the snapshots of the Lem and Sail libraries                   */
/*  in the prover_snapshots directory (which include copies of their                     */
/*  licences), is subject to the BSD two-clause licence below.                           */
/*                                                                                       */
/*  Copyright (c) 2017-2023                                                              */
/*    Prashanth Mundkur                                                                  */
/*    Rishiyur S. Nikhil and Bluespec, Inc.                                              */
/*    Jon French                                                                         */
/*    Brian Campbell                                                                     */
/*    Robert Norton-Wright                                                               */
/*    Alasdair Armstrong                                                                 */
/*    Thomas Bauereiss                                                                   */
/*    Shaked Flur                                                                        */
/*    Christopher Pulte                                                                  */
/*    Peter Sewell                                                                       */
/*    Alexander Richardson                                                               */
/*    Hesham Almatary                                                                    */
/*    Jessica Clarke                                                                     */
/*    Microsoft, for contributions by Robert Norton-Wright and Nathaniel Wesley Filardo  */
/*    Peter Rugg                                                                         */
/*    Aril Computer Corp., for contributions by Scott Johnson                            */
/*    Philipp Tomsich                                                                    */
/*    VRULL GmbH, for contributions by its employees                                     */
/*                                                                                       */
/*  All rights reserved.                                                                 */
/*                                                                                       */
/*  This software was developed by the above within the Rigorous                         */
/*  Engineering of Mainstream Systems (REMS) project, partly funded by                   */
/*  EPSRC grant EP/K008528/1, at the Universities of Cambridge and                       */
/*  Edinburgh.                                                                           */
/*                                                                                       */
/*  This software was developed by SRI International and the University of               */
/*  Cambridge Computer Laboratory (Department of Computer Science and                    */
/*  Technology) under DARPA/AFRL contract FA8650-18-C-7809 ("CIFV"), and                 */
/*  under DARPA contract HR0011-18-C-0016 ("ECATS") as part of the DARPA                 */
/*  SSITH research programme.                                                            */
/*                                                                                       */
/*  This project has received funding from the European Research Council                 */
/*  (ERC) under the European Union’s Horizon 2020 research and innovation                */
/*  programme (grant agreement 789108, ELVER).                                           */
/*                                                                                       */
/*                                                                                       */
/*  Redistribution and use in source and binary forms, with or without                   */
/*  modification, are permitted provided that the following conditions                   */
/*  are met:                                                                             */
/*  1. Redistributions of source code must retain the above copyright                    */
/*     notice, this list of conditions and the following disclaimer.                     */
/*  2. Redistributions in binary form must reproduce the above copyright                 */
/*     notice, this list of conditions and the following disclaimer in                   */
/*     the documentation and/or other materials provided with the                        */
/*     distribution.                                                                     */
/*                                                                                       */
/*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''                   */
/*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                    */
/*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                      */
/*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR                  */
/*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                         */
/*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT                     */
/*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF                     */
/*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND                  */
/*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,                   */
/*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                   */
/*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF                   */
/*  SUCH DAMAGE.                                                                         */
/*=======================================================================================*/

/* ********************************************************************* */
/* This file specifies the compressed floating-point instructions.
 *
 * These instructions are only legal if misa.C() and misa.F()
 * are set.
 */

/* ****************************************************************** */
union clause ast = C_FLWSP : (bits(6), regidx)

mapping clause encdec_compressed = C_FLWSP(ui76 @ ui5 @ ui42, rd)
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()
  <-> 0b011 @ ui5 : bits(1) @ rd : regidx @ ui42 : bits(3) @ ui76 : bits(2) @ 0b10
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()

function clause execute (C_FLWSP(imm, rd)) = {
  let imm : bits(12) = zero_extend(imm @ 0b00);
  execute(LOAD_FP(imm, sp, rd, WORD))
}

mapping clause assembly = C_FLWSP(imm, rd)
      if sizeof(xlen) == 32
  <-> "c.flwsp" ^ spc() ^ reg_name(rd) ^ sep() ^ hex_bits_6(imm)
      if sizeof(xlen) == 32

/* ****************************************************************** */
union clause ast = C_FSWSP : (bits(6), regidx)

mapping clause encdec_compressed = C_FSWSP(ui76 @ ui52, rs2)
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()
  <-> 0b111 @ ui52 : bits(4) @ ui76 : bits(2) @ rs2 : regidx @ 0b10
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()

function clause execute (C_FSWSP(uimm, rs2)) = {
  let imm : bits(12) = zero_extend(uimm @ 0b00);
  execute(STORE_FP(imm, rs2, sp, WORD))
}

mapping clause assembly = C_FSWSP(uimm, rd)
      if sizeof(xlen) == 32
  <-> "c.fswsp" ^ spc() ^ reg_name(rd) ^ sep() ^ hex_bits_6(uimm)
      if sizeof(xlen) == 32

/* ****************************************************************** */
union clause ast = C_FLW : (bits(5), cregidx, cregidx)

mapping clause encdec_compressed = C_FLW(ui6 @ ui53 @ ui2, rs1, rd)
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()
  <-> 0b011 @ ui53 : bits(3) @ rs1 : cregidx @ ui2 : bits(1) @ ui6 : bits(1) @ rd : cregidx @ 0b00
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()

function clause execute (C_FLW(uimm, rsc, rdc)) = {
  let imm : bits(12) = zero_extend(uimm @ 0b00);
  let rd = creg2reg_idx(rdc);
  let rs = creg2reg_idx(rsc);
  execute(LOAD_FP(imm, rs, rd, WORD))
}

mapping clause assembly = C_FLW(uimm, rsc, rdc)
      if sizeof(xlen) == 32
  <-> "c.flw" ^ spc() ^ creg_name(rdc) ^ sep() ^ creg_name(rsc) ^ sep() ^ hex_bits_7(uimm @ 0b00)
      if sizeof(xlen) == 32

/* ****************************************************************** */
union clause ast = C_FSW : (bits(5), cregidx, cregidx)

mapping clause encdec_compressed = C_FSW(ui6 @ ui53 @ ui2, rs1, rs2)
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()
  <-> 0b111 @ ui53 : bits(3) @ rs1 : cregidx @ ui2 : bits(1) @ ui6 : bits(1) @ rs2 : cregidx @ 0b00
      if sizeof(xlen) == 32 & haveRVC() & haveFExt()

function clause execute (C_FSW(uimm, rsc1, rsc2)) = {
  let imm : bits(12) = zero_extend(uimm @ 0b00);
  let rs1 = creg2reg_idx(rsc1);
  let rs2 = creg2reg_idx(rsc2);
  execute(STORE_FP(imm, rs2, rs1, WORD))
}

mapping clause assembly = C_FSW(uimm, rsc1, rsc2)
      if sizeof(xlen) == 32
  <-> "c.fsw" ^ spc() ^ creg_name(rsc1) ^ sep() ^ creg_name(rsc2) ^ sep() ^ hex_bits_7(uimm @ 0b00)
      if sizeof(xlen) == 32
