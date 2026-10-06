# 既知の不具合と TODO

`ecology_dev` を `master` にマージした際（2026-08-10, `97eb83e`）の検証で判明した問題をまとめる。

各項目は gfortran 15.2.0 / Ubuntu (WSL2) 上で実測により確認した。再現手順を各項目に記載する。

> **注記 (2026-10-06)**: 名称変更により `mod_reef_ecosys.F` は `mod_marine_comet.F` に、CPP フラグ `REEF_ECOSYS` は `MARINE_COMET` に、サブルーチン `reef_ecosys` 等は `marine_comet` 等に改名された。本文中のファイル名は新名称に更新したが、行番号・フラグ名・エラーログは記録当時のままである。
>
> **再検証 (2026-10-06)**: 名称変更の検証時に全13構成を再確認した。2026-08-12〜14 の `mod_coral.F` 改修（`9a2428d`, `2aba88f`）以降、`chamber` と `reef_flow` が再びビルドできなくなっている（項目8）。新たに判明した問題を項目8〜11に追記し、各項目の状態を現状に合わせて更新した。

## 優先度の概要

| # | 内容 | 影響 | 起因 |
|---|---|---|---|
| ~~[1](#1-ecosys_hiscsv-のヘッダとデータの列数が一致しない)~~ | ~~`ecosys_his.csv` のヘッダとデータの列数不一致~~ | 対応済み | マージ |
| [2](#2-reef_flow-構成がビルドできない) | `reef_flow` 構成がビルド不可 | 一度対応済みだが**再発**（項目8）。実行は入力データ待ち | 既存 |
| ~~[3](#3-blue_tide-を有効にするとコンパイルできない)~~ | ~~`BLUE_TIDE` 有効時にコンパイル不可~~ | 対応済み | 既存 |
| ~~[4](#4-mod_inputf-num_header-が暗黙の-save-になっている)~~ | ~~`Num_header` の暗黙 SAVE~~ | 対応済み | 既存 |
| ~~[7](#7-sg_flux_-が未初期化のまま-flux_-にコピーされる)~~ | ~~`Sg_Flux_*` が未初期化のまま `Flux_*` にコピーされる~~ | 対応済み | 既存 |
| [5](#5-他4つのプロジェクト構成がコンパイルできない) | 他4構成がコンパイル不可 | `coral_exp_T04` は対応済み。`chamber` は**再発**（項目8）。他2つは対象外 | 既存 |
| [6](#6-coral_nutrients-が有効化できない) | `CORAL_NUTRIENTS` が有効化できない | 当該機能が使用不能・**規模大** | 既存 |
| [8](#8-coral_size_dynamics-が再びコンパイルできない) | `CORAL_SIZE_DYNAMICS` が再びコンパイル不可 | `chamber`・`reef_flow` がビルド不可 | `2aba88f` |
| [9](#9-run-スクリプトのソース一覧に不足がある) | run スクリプトのソース一覧に不足 | `seagrass_chamber`・`coral/run.sh` がビルド不可 | 既存 |
| [10](#10-coral_exp_t04-の-in-が旧形式の-namelist) | `coral_exp_T04` の `.in` が旧形式の namelist | 実行開始直後に停止 | 既存 |
| [11](#11-coral-の診断出力に未初期化値が出る) | `coral` の診断出力に未初期化値 | 出力4列が実行ごとに変わる（計算本体は影響なし） | 既存 |

---

## 1. `ecosys_his.csv` のヘッダとデータの列数が一致しない

**状態**: 対応済み（`mod_marine_comet.F` のヘッダ行にラベルを移植）

`ECOSYS_TESTMODE` の出力で、ヘッダ行が **24列**、データ行が **49列** となり、列名と数値が対応していない。25列ぶんの数値に列名がない状態。

### 原因

マージで両ブランチの異なる版が組み合わさったため。

- **ヘッダ行** … `src/mod_marine_comet.F:1383`（ecology_dev 由来）。SEAGRASS は `sgrass_Pg`, `sgrass_R`, `sgrass_Pn` の **3列**のみ
- **データ行** … `src/mod_marine_comet.F:1448`（master 由来）。SEAGRASS は `GridPhot` 〜 `PO4stockRatio` の **23列**、加えて `SEDIMENT_ECOSYS` のフラックス **5列**

master では対応するヘッダが `mod_output.F` の `write_ecosys_his_lavel` にあり整合していたが、ecology_dev が出力系を再構成した際に同ルーチンと呼び出し側を削除。マージで ecology_dev 側（削除）を採用した結果、master のデータ行だけが残った。

### 実施した対応

`src/mod_marine_comet.F:1383` のヘッダに、master の `write_ecosys_his_lavel` が持っていたラベルを移植した。ラベル定義は以下で参照できる。

```sh
git show 613a115:src/mod_output.F | sed -n '723,768p'
```

`SEAGRASS` ブロックを次の23列に置換し、`SEDIMENT_ECOSYS` ブロックにフラックス5列を追加した。

```
sgrass_GrossPhot, sgrass_Grow, sgrass_Phot_lim, sgrass_Grow_lim,
sgrass_Resp, sgrass_NetPhot, sgrass_Dieoff,
sgrass_Wt, sgrass_LfWt, sgrass_RtWt, sgrass_LAI, sgrass_ELAP,
sgrass_ocean_flux_DIC, sgrass_ocean_flux_DO,
sgrass_ocean_flux_NH4, sgrass_ocean_flux_NO3, sgrass_ocean_flux_PO4,
sgrass_DOstockRatio, sgrass_DICstockRatio, sgrass_CH2OstockRatio,
sgrass_NH4stockRatio, sgrass_NO3stockRatio, sgrass_PO4stockRatio
```

```
sedeco_fluxDIC, sedeco_fluxDO, sedeco_fluxNO3, sedeco_fluxNH4, sedeco_fluxPO4
```

なお master のヘッダは NH4/NO3/PO4 系のラベルを `#if defined SEAGRASS_LEAF_NUTRIENT_UPTAKE` で囲っていなかった。データ行側は囲っているため、**同マクロが無効な構成では master 時点でも不一致が生じていた**。移植にあたってはデータ行と同じガードを付与し、この潜在的な不整合も解消してある。

### 確認結果

修正前は 24列 / 49列。修正後は両方 49列で一致する。

```sh
cd Projects/seagrass && sh run_win.sh
awk -F',' 'NR<=2{print NR": "NF" 列"}' output/01-ecosys_his.csv
# 1: 49 列
# 2: 49 列
```

関連マクロ（`CORAL_POLYP`, `SEAGRASS`, `MACROALGAE`, `SEDIMENT_ECOSYS`, `CARBON_ISOTOPE`,
`SEAGRASS_LEAF_NUTRIENT_UPTAKE`）の 64 通りすべての組み合わせで、ヘッダとデータの
列数が一致することを確認済み。

---

## 2. `reef_flow` 構成がビルドできない

**状態**: 2-a・2-b・2-c とも対応済み。ビルドとリンクが通り、全 namelist も読める。ただし**入力データが未配置のため実行はまだできない**（2-d）。

> **2026-10-06 追記**: その後の `mod_coral.F` 改修により、`CORAL_SIZE_DYNAMICS` ブロックが再びコンパイルできなくなり、`reef_flow` はビルド不可に戻っている（項目8）。2-d の入力データも引き続き未配置。

`Projects/reef_flow/cppdefs.h` を使うと失敗していた。独立した原因が3つあった。

### 2-a. `FLOW_OUTPUT_INTERVAL` が未定義 — 対応済み（`8165c8c`）

```
src/mod_reef_flow.F:197:48:
  197 |         dsec=date*86400.0d0+FLOW_OUTPUT_INTERVAL*60.0d0
Error: Symbol 'flow_output_interval' at (1) has no IMPLICIT type
```

`Projects/reef_flow/cppdefs.h` だけが、他の全プロジェクトが持つ「出力間隔ブロック」を欠いていた。同じ値のブロックを追加して解消。

`src/mod_reef_flow.F:144` にあるコメントアウトされた `parameter` 定義は旧方式の名残で、`mod_coral.F:1974`、`mod_marine_comet.F:513`、`mod_sedecosys.F:782` にも同じものがある。ソース側の変更は不要。

これにより `ECOSYS_OUTPUT_INTERVAL` 未定義も併せて解消した。`main.F` が致命的エラーで打ち切られていたため表面化していなかったもの。

### 2-b. `write_env_vprof` に `USE mod_reef_flow` がない — 対応済み（`c88bb7f`）

```
src/mod_output.F:490:22:                        ← 行番号は修正前のもの
  490 |            , REEF(1)%Qrc(1,1), REEF(1)%Qch(1,1), REEF(1)%el (1,1)          &
Error: Symbol 'reef' at (1) has no IMPLICIT type
```

`mod_output.F` には `REEF(1)%...` を参照するサブルーチンが2つある。

| サブルーチン | REEF 参照 | `USE mod_reef_flow` |
|---|---|---|
| `write_env_data` | 680行 | あり（629行、`#if defined REEF_FLOW` 付き） |
| `write_env_vprof` | 493行 | 修正で追加（292行） |

出力行が両者で完全に同一なことから、ブロックをコピーした際に `USE` を持ってこなかったものと見られる。Fortran の `USE` はスコープ単位なので `write_env_data` のものは届かない。`write_env_vprof` に同じガード付き `USE` を追加して解消。

`REEF_FLOW` を define するのは `reef_flow` だけなので、他構成では当該行ごと無効化され表面化しなかった。

### 2-c. `main.F` の `reef_ecosys` 呼び出しにガードがない — 対応済み

```
main.F:(.text+0x14a8): undefined reference to `allocate_reef_ecosys_'
main.F:(.text+0x14d1): undefined reference to `initialize_reef_ecosys_'
main.F:(.text+0x3081): undefined reference to `reef_ecosys_'
```

`mod_reef_ecosys` は本体全体が `#if defined REEF_ECOSYS` で囲まれている（`src/mod_marine_comet.F:10`）。一方 `main.F` の3つの呼び出し（267, 275, 474行）は囲まれていない。

`reef_flow` は `REEF_ECOSYS` がコメントアウトされた「流動のみ」構成だったため、モジュール本体が空になり実体が見つからなかった。

`REEF_ECOSYS` は 2020-12-03 (`a670be2`) 時点では有効だったが、2022-10-27 の改修 (`f462cf1`) でコメントアウトされ、以後 `reef_flow` は更新されていなかった。約4年間ビルドできない状態が続いていたことになる。

取り得る対処は2つあり、`reef_flow` を「流動だけを見る構成」とするか「流動＋生態系」とするかで変わる。

1. **`main.F` の呼び出しを `#if defined REEF_ECOSYS` で囲む** — 流動のみモードを成立させる。ただし `main.F` はトレーサ配列など生態系側の変数を広く参照しているため、囲む範囲の見極めが要る。未検証
2. **`REEF_ECOSYS` を有効に戻す** — 流動＋生態系のフル構成にする

**選択肢2を採用した。** 項目5で `chamber` を直した結果、成立するようになったもの。`cppdefs.h` を2行変更した。

```c
Projects/reef_flow/cppdefs.h:14   /*#define REEF_ECOSYS*/       -> #define REEF_ECOSYS
Projects/reef_flow/cppdefs.h:34   #  define SEDIMENT_EMPIRICAL  -> コメントアウト
```

2行目が必要なのは、`SEDIMENT_EMPIRICAL` が `#if defined REEF_ECOSYS` の内側にあり、1行目だけ変えると死んだ経路（項目5参照）が有効になってしまうため。

これで有効になるのは `CORAL_POLYP`（+`CORAL_ZOOXANTHELLAE`, `CORAL_PHOTOINHIBITION`, `CORAL_SIZE_DYNAMICS`）、`FOODWEB`、`MACROALGAE`、`SEAGRASS`、`SEDIMENT_ECOSYS`、`NUTRIENTS`、`ORGANIC_MATTER`。

### 2-d. `reef_flow_01.in` の更新と入力データ — 入力データは未配置

`reef_flow_01.in` も2022年の改修前の形式のままで、ビルドが通った後も実行時に順に失敗した。

1. `&sedeco_config` が無い → `main.F:159` で停止
2. `&sgrass_config` が無い → `main.F:163` で停止
3. `&initial` が旧変数名 → `mod_param.F:337` で `Cannot match namelist object name doc1_0`

`&initial` をスカラー個別指定から配列形式へ移行し、不足の2グループを追加して解消した。

| 旧 | 新 |
|---|---|
| `DOC1_0`, `DOC2_0` | `DOC_0`（Ndom=2） |
| `POC1_0`, `POC2_0` | `POC_0`（Npom=3） |
| `Phyt1_0`〜`Phyt3_0` | `PhyC_0`（Nphy=4） |
| `Zoop1_0` | `ZooC_0`（Nzoo=1） |
| `PIC1_0` | `PIC_0`（Npim=2） |
| `p_coral1_0`, `p_coral2_0` | `p_coral_0`（Ncl=2） |
| `DON*_0`, `PON*_0`, `DOP*_0`, `POP*_0` | 削除（現行 namelist はコメントアウトされており受け付けない） |

旧ファイルに対応値が無かった `POC_0` の3要素目（粗大POC）と `PhyC_0` の4要素目（藍藻）は 0.0 とした。`&sedeco_config` は `Projects/seagrass` の値を流用したが、`p_sand_0 = 0.0`、`p_sgrass_0 = 0.0` のため実質不活性。

**残っているのは入力データのみ。** `reef_flow_01.in` が参照する強制データ13ファイルが `input/` に存在しない。

```
input/Ishigaki_frc_JMAobs_2018_{swrad,lwrad_down,Tair,Pair,wind,rain,Qair,cloud}.nc
input/PPFD.txt
input/level2017.txt, input/level2018.txt
input/temp2017.txt, input/temp2018.txt
```

データは作成済みとのことで、配置後に実行確認を行う。

> **注意**: このデータが無い状態で実行すると、Fortran の `open` 文が既定で存在しないファイルを作成するため、`input/` に空ファイルが生成される。実行前にデータを配置すること。

### 再現手順

```sh
cd Projects/reef_flow && sh run.sh
```

---

## 3. `BLUE_TIDE` を有効にするとコンパイルできない

**状態**: 対応済み。`pelagic_bentic` で有効化し、実行まで確認した。

### `BLUE_TIDE` の役割

無効時、`H2S` と `S0` は `mod_marine_comet.F` の内部変数で毎回ゼロにされる（1221〜1223行）ため、硫化物は蓄積しない。有効にすると呼び出し側が保持する**予報変数**に昇格する。

| | 無効 | 有効 |
|---|---|---|
| `H2S`, `S0` | 内部変数（475〜478行） | `intent(in)` 仮引数（363〜365行） |
| `dH2S_dt`, `dS0_dt` | なし | `intent(out)` 仮引数（411〜413行） |

データの流れは、`mod_sedecosys.F:1517` が堆積物からの `Flux_H2S` を出し、`mod_marine_comet.F:1366` が最下層に適用、`mod_foodweb.F` が水柱の硫酸還元・酸化を加える、というもの。

### 原因

`main.F` に `BLUE_TIDE` の記述が一行も無かった。`mod_marine_comet.F` は同マクロ下で `reef_ecosys` の引数を4つ追加するため、`CALL` の引数リストが4つぶんずれ、以降が総崩れになって rank mismatch が10件発生していた。`mod_marine_comet.F` / `mod_foodweb.F` / `mod_sedecosys.F` 側は実装済みだった。

### 実施した対応

`COT_STARFISH` と同じく、正式なトレーサとして実装した。

**`mod_param.F`** — `iH2S(N_Ssp)` と `iS0(N_Ssp)` を追加。`iTIC(N_Csp)` と同じ形式で採番し、初期値はゼロ。`Nid` は自動採番なので `t` と `dtrc_dt` の確保にも反映される。

**`main.F`** — 宣言・確保・トレーサからの読み出し・`CALL` 引数・`dtrc_dt` への書き戻しを、`COT_STARFISH` と同じ位置に追加。時間積分は既存ループがそのまま扱う。

### 確認結果

`Projects/pelagic_bentic/cppdefs.h` で `BLUE_TIDE` を有効にした。

- 全19ファイルのコンパイルとリンクが成功
- トレーサ数 `Nid` が 77 → 81 に増加（H2S・S0 × `N_Ssp`=2）
- 1日分の積分が完走
- `BLUE_TIDE` 無効版と出力を比較すると、`ecosys_his.csv` の26行中24行に差異。相対差は `dDO_dt` で約 1.7e-8

差が倍精度の丸め水準（~1e-16）より8桁大きいことから、硫化物が実際に非ゼロになり DO に効いていると判断できる。ただし `pelagic_bentic` の既定設定は貧酸素ではないため、青潮と呼べる規模の蓄積は起きていない。**現象としての妥当性検証には、貧酸素条件での長期積分が別途必要。**

なお H2S / S0 は出力ルーチンの対象外なので、値を直接確認するには出力の追加が要る。

### 副次的に判明した既存バグ（対応済み）

検証中、`pelagic_bentic` が `BLUE_TIDE` の有無にかかわらず実行時に落ちることが判明した。

```
mod_input.F, around line 148: Error allocating 521034539008 bytes: Cannot allocate memory
```

`in_file` は `main.F:120` で20要素宣言されているが、`.in` ファイルは12要素しか与えない。13〜20番目（`isgd`, `iinpH`〜`iinPO4`）が未初期化のまま `allocate` に使われていた。20要素を書いているのは `seagrass_chamber` のみで、他の全プロジェクトが12要素。`seagrass` がこれまで動いていたのは、未初期化領域がたまたま無害な値だっただけ。

`main.F` の namelist 読み込み前に `in_file(:) = 0` を追加して解消した。

## 4. `mod_input.F`: `Num_header` が暗黙の SAVE になっている

**状態**: 対応済み

```fortran
src/mod_input.F:52:    integer :: Num_header = 0
```

Fortran では宣言時に初期化子を書くと暗黙の `SAVE` 属性が付き、初期化はプログラム開始時に一度だけ実行される。呼び出しごとにはゼロ初期化されない。

**実害は無かった。** `read_data` は `main.F:267` で起動時に1回しか呼ばれず、`Num_header` は `read_infiles_ascii` に渡す直前で必ず代入される（`#ifdef INPUT_ROMS_NCDUMP` / `#else` のどちらの分岐でも代入されるので、前回値が読まれる経路がない）。

同じ機構で実害を出した `mod_foodweb.F` の `d*_dt`（`571b559` で修正）との違いは次のとおり。

| | `mod_foodweb.F` | `Num_header` |
|---|---|---|
| 使用前の代入 | なし（`decomposition` が加算） | あり（必ず） |
| 呼び出し回数 | 全タイムステップ×全格子 | 1回 |
| 実害 | あり | なし |

将来の落とし穴を断つため、宣言と代入を分けた。`read_data` が複数回呼ばれるようになったり、代入を伴わない分岐が追加された時点で静かに壊れる書き方だった。

```fortran
    integer :: Num_header      ! 初期化子を外す
    ...
    Num_header = 0             ! 実行文で代入
```

`seagrass` を実行して `ecosys_his.csv` がビット単位で一致することを確認済み（挙動不変）。

### 関連する対応済みの修正

同じ機構による不具合として、以下も対応済み。

- `571b559` — `mod_foodweb.F` の `d*_dt` 系。`decomposition` が `intent(inout)` で加算する変数が全タイムステップにわたり累積していた
- `0a08ab6` — `mod_geochem.F` の `l2mol` を `parameter` 化（`!$acc routine seq` 下の静的変数を回避）、`mod_reef_flow.F` の `dsec` に `save` を明示

全ソースを走査済みで、**手続き内の暗黙 SAVE はこれで全て解消**した。

---

## 5. 他4つのプロジェクト構成がコンパイルできない

**状態**: `chamber`・`coral_exp_T04` は対応済み。`sedecosys_dev_muto`・`test` は**対応しない方針**（使用しないプロジェクトのため）。

> **2026-10-06 追記**: `chamber` は `CORAL_SIZE_DYNAMICS` を有効にしているため、項目8によって再びビルド不可になっている。`coral_exp_T04` はビルドできるが、`.in` が旧形式のため実行できない（項目10）。

`Projects/` 配下の13構成を全て確認したところ、`reef_flow` 以外にも4つが失敗していた。

| 構成 | 状態 |
|---|---|
| `coral_exp_T04` | 対応済み（`e04cf5c`） |
| `chamber` | 対応済み（`a0af00f`） |
| `sedecosys_dev_muto` | 対応しない。`cppdefs.h` の出力間隔ブロック欠落（項目 2-a と同型）なので、必要になれば同じ方法で直せる |
| `test` | 対応しない。`chamber` と同型 |

### 共通の根本原因

`c0b9c87`（2026-01-16「Bugfix: coral calcification process」）でサンゴの炭素プールが分割された。

```fortran
- real(8), pointer :: QC(:,:,:,:)     ! 初期値 300.0 umolC/cm2
+ real(8), pointer :: QCe(:,:,:,:)    ! 初期値  15.0
+ real(8), pointer :: QCv(:,:,:,:)    ! 初期値 290.0  ← Tanaka et al. 2018 のコメントを継承
+ real(8), pointer :: QCr(:,:,:,:), QCh(:,:,:,:)
```

このとき、当時どのプロジェクトも有効にしていなかった `CORAL_SIZE_DYNAMICS` と `CORAL_MUCUS` のブロックが取り残された。同様に `QC0(2) = [250.0d0, 250.0d0]` の宣言が `d09cbdf` で削除されていた。

`coral_exp_T04` は `CORAL_MUCUS` の `rQC` → `rQCe`、`chamber` は `CORAL_SIZE_DYNAMICS` の `%QC` → `%QCv` と `QC0` の復活で解消。プール選択の根拠は、粘液側は直後に `F_QCe` へ計上していること、サイズ動態側は閾値 `QC0=250` が分割前の `QC=300` と同オーダー（`QCe` は 15）であること。

### `chamber` で追加で必要だったもの

`SEDIMENT_EMPIRICAL` を無効化した。この経路は成立していない。

- `mod_sedecosys_empirical.F` はどの run スクリプトにも含まれない
- `USE mod_sedecosys_empirical` がソース中に存在しない
- 呼び出し側 `mod_marine_comet.F:1188` が rank2 の引数に `NH4(1)` を渡している

選択していたのは、当時ビルドできなかった3構成（`chamber`, `reef_flow`, `test`）だけだった。`chamber` と `reef_flow` では無効化済み。経験式の堆積物モデルを再び使うなら、モジュールの復活から別途必要になる。

また `mod_macroalgae.F` の `rQC` / `rDIC` が配列宣言なのにスカラーとして使われていた既存バグも解消した（`aC_resp` のエラーに隠れていた）。

なお `CORAL_NUTRIENTS` 配下にも同種の取り残しがあるが、規模が大きいため項目6として別建てにした。

### 再現手順（対応しない2構成）

```sh
for P in sedecosys_dev_muto test; do
  ( cd Projects/$P && sh run_win.sh )
done
```

---

## 6. `CORAL_NUTRIENTS` が有効化できない

**状態**: 未対応 / 規模大

> **2026-10-06 再確認**: `mod_coral.F` の改修（`9a2428d`, `2aba88f`）で行番号が大きく移動し、エラー件数も 21件 → **15件**に変わった（`Projects/coral` で有効化した場合）。(4) の粘液プレースホルダは実装済みになっている。以下の行番号は 2026-10-06 時点のもの。

サンゴの窒素・リン動態を扱うオプション。**どのプロジェクトも有効にしておらず**、そのため長期間コンパイルされないまま周辺の改修から取り残されている。有効化すると `mod_coral.F` だけで **15件**のエラーが出る（2026-08-10 時点では21件）。

他のモジュール（`mod_marine_comet.F`, `main.F` など）にエラーは波及しないので、修正は `mod_coral.F` に閉じる。

### 再現手順

`Projects/coral/cppdefs.h:55` のコメントを外してビルドする。

```sh
sed -i 's|^/\*#\( *\)define CORAL_NUTRIENTS\*/|#\1define CORAL_NUTRIENTS|' Projects/coral/cppdefs.h
cd Projects/coral && sh run_win.sh
```

### 問題の内訳

4種類に分かれる。上から順に直さないと、後続のエラーが隠れて見えない。

**(1) 構文の破損（2箇所）**

`mod_coral.F:1495〜1496` — 継続行の `&` が無く、2文に分断されている。

```fortran
    c_SQC=min((Flux_NH4 +Flux_NO3 )*c_CNP(nC)/c_CNP(nN)     ← 末尾に & が必要
                 ,Flux_PO4 *c_CNP(nC)/c_CNP(nP))
```

`mod_coral.F:1843〜1845` — 逆に `&` が余分で、次の代入文と連結されている。現在は `CORAL_SIZE_DYNAMICS` ブロック（項目8）の内側にあるため、`Projects/coral` のように同マクロが無効な構成ではエラーとして現れない。

```fortran
    F_Cgrowth(iCt) = g_max(n)*min( 1.0d0 - QC0(n)/CORAL(ng)%QCv(iCt,n,i,j) ,    &
                          min(1.0d0 - QN0(n)/CORAL(ng)%QNv(iNt,n,i,j),     &
                              1.0d0 - QP0(n)/CORAL(ng)%QPv(iPt,n,i,j) ) )  &   ← この & が余分
    F_Cgrowth(iCt) = max(F_Cgrowth(iCt), 0.0d0)
```

**(2) 炭素プール分割に伴う旧名参照**

項目5と同じく `c0b9c87` の分割に追随できていない。窒素・リン側も `QN` → `QNe`/`QNv`/`QNr`/`QNh`、`QP` → `QPe`/… と分割されている。

| 行 | 内容 |
|---|---|
| 1415 | `CORAL(ng)%QN (isp,n,i,j)` |
| 1498 | `CORAL(ng)%QC(n,i,j)` （添字数も旧形式のまま） |
| 1870〜1872 | `CORAL(ng)%QC` / `%QN` / `%QP`（`CORAL_SIZE_DYNAMICS` 併用時のみ） |
| 2562, 2563 | `ZOOX(ng)%QN`, `ZOOX(ng)%QP`, `ZOOX(ng)%QC` |
| 2789 | `ZOOX(ng)%QN`, `ZOOX(ng)%QP` |

`t_coral` / `t_zoox` のどちらのプールに対応させるかは、項目5と同様に用途から判断する必要がある。

**(3) 未宣言の変数**

宣言が失われている、または一度も書かれていない。

```
rPO4coe, c_SQC, c_SQN, c_SQP, c_CNP, nC, nN, nP, tempb,
F_Ngrowth, F_Pgrowth（CORAL_SIZE_DYNAMICS 併用時のみ）
```

2026-08-10 時点で挙げていた `rQN`, `rQP` は、その後の改修で宣言済みになった。

`c_CNP(nC)` / `c_CNP(nN)` / `c_CNP(nP)` は C:N:P 比を引く配列とその添字定数と見られるが、定義が見当たらない。`QN0` と `QP0` は宣言されている。

**(4) 未実装のプレースホルダ — 2026-10-06 時点で実装済み**

現在は `mod_coral.F:1536〜1537` で `F_Nmucus = k_mucus(n,m) * CORAL(ng)%QNe(iNt,n,i,j)*1.d3`（リンも同形）と定式化されている。以下は 2026-08-10 時点の記録。

`CORAL_MUCUS` と併用したときのみ通る箇所（`mod_coral.F:1139` の `#  if defined CORAL_NUTRIENTS` 配下）。

```fortran
      F_Nmucus(m) = ???
      F_Pmucus(m) = ???
```

粘液に含まれる窒素・リンの放出量をどう決めるかが未定。**ここはモデルの定式化そのものが必要**で、機械的な修正では済まない。

`CORAL_MUCUS` を有効にする `coral_exp_T04` で `CORAL_NUTRIENTS` も併せて有効化する場合は、この2行の実装が前提になる。

### 進め方の目安

(1) と (3) は機械的に直せる。(2) は項目5と同じ判断（どのプールを指すか）が要る。(4) は実装済み。

そのため「(1)(3) を直して残りのエラーを可視化する」→「(2) をプールごとに判断」の順が現実的。`CORAL_SIZE_DYNAMICS` との併用分は項目8と併せて扱う。

---

## 7. `Sg_Flux_*` が未初期化のまま `Flux_*` にコピーされる

**状態**: 対応済み / マージ前から存在（master の `Sg_Flux_*` 導入時から）

`env_his.csv` の `RDOC_13C` 列に `-0.52E-311` や `0.41E+227` といった異常値が出力される。実行ごとに値が変わる。

### 原因

`mod_marine_comet.F` で、海草モジュールに渡す中継配列 `Sg_Flux_*` がどこでもゼロ初期化されていない。

```fortran
 896:    Flux_DOC(:,:) = 0.0d0            ← Flux_DOC は初期化される
1047:          , Sg_Flux_DOC(:,iLDOM)   & ← 海草が書くのは iLDOM 列だけ
1064:        Flux_DOC = Sg_Flux_DOC       ← 配列全体をコピー。iRDOM 列は未初期化のゴミ
1160:        dDOC_dt(:,:,1) = dDOC_dt(:,:,1) - Flux_DOC(:,:) * cff
```

`Flux_DOC` は896行で正しくゼロ初期化されるが、1064行の代入が**配列全体を上書き**するため無効化される。海草が書き込むのは `iLDOM` 列のみなので、`iRDOM` 列は `Sg_Flux_DOC` の未初期化値がそのまま `dDOC_dt` に入り、時間積分でトレーサに蓄積していく。

同じ構造の中継配列が他にもある。海草が一部の要素しか書かないもの:

| 配列 | 海草が書く範囲 | 未初期化のまま残る範囲 |
|---|---|---|
| `Sg_Flux_DOC(N_Csp,Ndom)` | `(:,iLDOM)` | `(:,iRDOM)` |
| `Sg_Flux_POC(N_Csp,Npom)` | `(:,iCPOM)` | `(:,iLPOM)`, `(:,iRPOM)` |
| `Sg_Flux_PON(N_Nsp,Npom)` | `(:,iCPOM)` | 同上 |
| `Sg_Flux_POP(N_Psp,Npom)` | `(:,iCPOM)` | 同上 |

`Sg_Flux_DIC` / `Sg_Flux_DO` / `Sg_Flux_NO3` / `Sg_Flux_NH4` / `Sg_Flux_PO4` は全要素が書かれるので影響しない。

**注意**: これは 13C 固有の問題ではない。`RDOC_13C` で目立つのは、難分解性 DOC がほとんど変化せず初期のゴミが残り続けるため。`CARBON_ISOTOPE` を有効にした構成では 13C 成分が実際に使われるので、より広範囲に影響しうる。

### 影響範囲

`SEAGRASS` を有効にする構成が該当する。マージ前の master（`613a115`）にも同じ構造があり、`Sg_Flux_*` を導入した時点からの問題。

### 実施した対応

既存の `Flux_*` ゼロ初期化ブロック（`mod_marine_comet.F:908` 付近）の直後で、`Sg_Flux_*` も併せてゼロ初期化した。宣言はガードされていないので無条件でよい。

```fortran
    Sg_Flux_DIC(:) = 0.0d0
    Sg_Flux_DO     = 0.0d0
    Sg_Flux_NO3(:) = 0.0d0
    Sg_Flux_NH4(:) = 0.0d0
    Sg_Flux_PO4(:) = 0.0d0
    Sg_Flux_DOC(:,:) = 0.0d0
    Sg_Flux_POC(:,:) = 0.0d0
    Sg_Flux_PON(:,:) = 0.0d0
    Sg_Flux_POP(:,:) = 0.0d0
```

`seagrass` を実行して確認した結果は次のとおり。

- `RDOC_13C` は全行 `0.0` になった
- `env_his.csv` 全列を走査し、`|x|>1e30` や非正規化数といった異常値が残っていないことを確認
- `ecosys_his.csv`（物質収支の出力）は修正前とビット単位で完全一致。今回のゴミは `env_his.csv` の当該列にとどまっていた

> **2026-10-06 再確認**: 現在の `seagrass` では `RDOC_13C` が全行 0.0 ではなく、0 から単調に増えて最大 約5e-10 になる。`env_his.csv` 全列に `|x|>1e30` や非正規化数は無く、別ビルド間で出力がビット単位で一致するため、未初期化のゴミではなく計算由来の値と判断した。`seagrass` は `CARBON_ISOTOPE` 無効のため 13C 成分に値が入る経路自体は要確認だが、本項目の不具合の再発ではない。

### 再現手順

```sh
cd Projects/seagrass && sh run_win.sh
awk -F',' 'NR<=4{print NR": "$18}' output/01-env_his.csv   # RDOC_13C 列
```

---

## 8. `CORAL_SIZE_DYNAMICS` が再びコンパイルできない

**状態**: 未対応 / 2026-10-06 判明

項目5で `chamber` を、項目2で `reef_flow` をビルドできるようにしたが、その後の `mod_coral.F` 改修で再び失敗するようになった。両構成とも `CORAL_SIZE_DYNAMICS`（と `CORAL_ZOOXANTHELLAE`）を有効にしている。

```
src/mod_coral.F:1853:4:
 1853 |     F_Cgrowth(iCt) = 5.0d-5 * (CORAL(ng)%QCv(iCt,n,i,j) - QC0(n))
Error: Function 'f_cgrowth' at (1) has no IMPLICIT type
```

### 原因

`2aba88f`（2026-08-12「Updated: coral metabolic parameters and functions」）で `coral_polyp` の炭素収支が `F_bio` / `F_Crest` / `F_Cext` に再構成され、`F_Cgrowth` の宣言が削除された。`CORAL_SIZE_DYNAMICS` ブロック（`mod_coral.F:1825〜1885`）はまだ旧変数を参照している。

ソース中にも既に TODO コメントがある（`mod_coral.F:1826〜1831`）。それによると、このブロックには次の問題が残っている。

- `F_Cgrowth` / `F_Ngrowth` / `F_Pgrowth` を配列として参照しているが、もう存在しない
- `E_m` が一度も代入されないまま読まれる
- `CORAL(ng)%G` が 0 の場合の割り算に対策が無い
- `CORAL_NUTRIENTS` 分岐の継続行 `&` が余分（項目6 (1)）

改修するときは、被度の増加の原資として `QCext`（窒素・リンは `QNext` / `QPext`）を使うべき、とコメントにある。

### 影響

`chamber` と `reef_flow` がビルドできない。どちらも `CORAL_SIZE_DYNAMICS` を外せばこのエラーは消えるが、それではサイズ動態を使わない構成になる。サイズ動態を改修するか、当面は両構成で無効化するかの判断が要る。

### 再現手順

```sh
cd Projects/reef_flow && sh run.sh
```

---

## 9. run スクリプトのソース一覧に不足がある

**状態**: 未対応 / 2026-10-06 判明

以下の run スクリプトは、他の構成が含めている `mod_aquaculture.F`、`mod_deb_model.F`、`mod_bivalve.F` をコンパイル対象に含めていない。

| スクリプト |
|---|
| `Projects/seagrass_chamber/run_win.sh` |
| `Projects/seagrass_chamber/run_mac.sh` |
| `Projects/coral/run.sh` |

`mod_param.F` が `USE mod_aquaculture` するため、`mod_aquaculture.mod` が見つからずビルドが止まる。

```
Fatal Error: Cannot open module file 'mod_aquaculture.mod' for reading at (1): No such file or directory
```

`seagrass_chamber` の `cppdefs.h` 自体は、他の構成と同じソース一覧（例: `Projects/coral_d13C/run_win.sh`）でビルドすると成功する。2026-08-10 の確認で `seagrass_chamber` を「ビルド成功」としていたのは、構成ファイルを共通のソース一覧でビルドした結果で、スクリプト自体は確認していなかったと考えられる。

### 対処

3つのスクリプトのソース一覧に、`mod_aquaculture.F`（`mod_param.F` の前）、`mod_deb_model.F`、`mod_bivalve.F`（`mod_coral.F` の前）を他の構成と同じ順で追加する。

---

## 10. `coral_exp_T04` の `.in` が旧形式の namelist

**状態**: 未対応 / 2026-10-06 判明

ビルドは通る（項目5）が、実行直後に停止する。

```
At line 370 of file ../../src/mod_param.F (unit = 5, file = 'stdin')
Fortran runtime error: Cannot match namelist object name doc1_0
```

項目 2-d で `reef_flow_01.in` について対応したものと同じ問題で、`&initial` がスカラー個別指定（`DOC1_0` など）の旧形式のまま。該当するのは次の2ファイル。

- `Projects/coral_exp_T04/coral_pre_2w.in`（`run.sh` が使用）
- `Projects/coral_exp_T04/coral_01.in`

`run_main.sh` が使う `coral_main_*.in`（10ファイル）は新形式（`DOC_0` など）で書かれており、該当しない（実行は未確認）。

### 対処

項目 2-d の対応表に従い、`&initial` を配列形式へ移行する。不足する namelist グループがあれば併せて追加する。

---

## 11. `coral` の診断出力に未初期化値が出る

**状態**: 未対応 / 2026-10-06 判明

`Projects/coral`（`run_win.sh`, `coral_01.in`）で、次の出力列に非正規化数（~1e-310）などのゴミが出る。同じバイナリを2回実行しても値が変わる。

| ファイル | 列 |
|---|---|
| `crl01_his.csv`, `crl02_his.csv` | `F_Csec`, `F_detox`, `F_dam` |
| `zoo01_his.csv`, `zoo02_his.csv` | `Cg_bio` |

それ以外の列と、他のファイル（`ecosys_his.csv`, `env_his.csv` など）は実行間でビット単位に一致する。そのため、ゴミは出力専用の局所変数に限られ、予報変数には波及していないと考えられる。

### 原因

いずれも**宣言と出力しか無く、どこでも代入されていない**局所変数。構成によらず未初期化のまま出力される。

- `F_Csec`, `F_detox`, `F_dam` — `mod_coral.F:1108〜1114` で宣言、`2240` 行で出力
- `Cg_bio` — `mod_coral.F:2515` で宣言、`2786` 行で出力

履歴上も代入文が存在した時期は無く、`c0b9c87`（2026-01-16「Bugfix: coral calcification process」）で出力列に加えられた時点から未初期化のまま出力されていた。

### 対処

モデルとして意味のある値を計算して代入するか、出力列ごと削除する。当面の対策としてゼロ初期化する手もあるが、意味の無い列が残ることになる。

### 再現手順

```sh
cd Projects/coral && sh run_win.sh && cp output/01-crl01_his.csv /tmp/a.csv
sh run_win.sh && cmp /tmp/a.csv output/01-crl01_his.csv   # 差異が出る
```

---

## 検証環境

- gfortran 15.2.0 (Ubuntu 15.2.0-16ubuntu1)
- Linux 6.18.33.2-microsoft-standard-WSL2

2026-10-06 の再検証は次の環境で行った。

- gfortran 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1)
- Linux 6.18.40.1-microsoft-standard-WSL2

### 構成ごとのビルド状況

`Projects/` 配下の全13構成を確認した結果（2026-10-06 更新）。「共通一覧」は `Projects/coral_d13C/run_win.sh` のソース一覧を各構成の `cppdefs.h` でビルドした結果。

| 状態 | 構成 |
|---|---|
| ビルド・リンクとも成功 | `coral`, `coral_d13C`, `coral_exp_T04`, `foodweb`, `oyster`, `pelagic_bentic`, `sedecosys`, `seagrass` |
| 共通一覧なら成功、自身の run スクリプトでは失敗 | `seagrass_chamber`、および `coral/run.sh`（項目9） |
| 失敗（再発） | `chamber`, `reef_flow`（項目8） |
| 対応しない（使用しないプロジェクト） | `sedecosys_dev_muto`, `test`（項目5） |

### 実行確認

2026-10-06 に、次の構成で各1ケースを実行した。

| 構成 | 入力 | 結果 |
|---|---|---|
| `coral` | `coral_01.in` | 完走（診断出力4列に未初期化値。項目11） |
| `coral_d13C` | `coral_01.in` | 完走（365日） |
| `coral_exp_T04` | `coral_pre_2w.in` | 開始直後に停止（項目10） |
| `foodweb` | `foodweb_2023NP.in` | 完走 |
| `oyster` | `oyster_x1.0.in` | 完走 |
| `pelagic_bentic` | `pelagic_bentic.in` | 完走 |
| `seagrass` | `seagrass_test1.in` | 完走 |
| `sedecosys` | `sedecosys.in` | 完走 |

`reef_flow` は入力データ未配置のため実行未確認（項目 2-d）。`chamber` は `.in` ファイルが無く、`runeco_s*.sh` が `mod_*.F90` や `ecosys_test5.F90` という現存しないファイル名を参照しているため実行未確認。
