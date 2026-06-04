import pandas as pd
import os
import glob

# ══════════════════════════════════════════
#  설정
# ══════════════════════════════════════════
FOLDER = r'C:\Users\20016260\Documents\고서기25\고객서비스 만족도조사\자가관리\로데이터 정리'
DATE_COL   = '설문일자'          # 날짜 기준 컬럼
SAT_COLS   = ['답변6', '답변7']  # 만족도 답변 컬럼
START_DATE = '2026-01-01'
END_DATE   = '2026-05-31'
TARGET     = ['매우불만족', '불만족']

# ══════════════════════════════════════════
#  파일 불러오기
# ══════════════════════════════════════════
files = glob.glob(os.path.join(FOLDER, '*.xlsx'))
print(f'\n📂 파일 {len(files)}개 발견')

dfs = []
for f in files:
    try:
        df = pd.read_excel(f, dtype=str)
        # 중복 컬럼(답변1 등) 처리: 주관식 답변1 컬럼 이름 변경
        cols = list(df.columns)
        seen = {}
        new_cols = []
        for c in cols:
            if c in seen:
                seen[c] += 1
                if '주관식' in str(cols[cols.index(c) - 1]) or seen[c] > 1:
                    new_cols.append(f'{c}_주관식{seen[c]}')
                else:
                    new_cols.append(c)
            else:
                seen[c] = 0
                new_cols.append(c)
        df.columns = new_cols
        dfs.append(df)
        print(f'  ✓ {os.path.basename(f)}  ({len(df):,}행)')
    except Exception as e:
        print(f'  ✗ {os.path.basename(f)}  오류: {e}')

if not dfs:
    print('\n❌ 읽을 수 있는 파일이 없습니다. 폴더 경로를 확인해주세요.')
    exit()

df_all = pd.concat(dfs, ignore_index=True)
print(f'\n📊 전체 합계: {len(df_all):,}건')

# ══════════════════════════════════════════
#  날짜 필터 (2026.01 ~ 2026.05)
# ══════════════════════════════════════════
df_all[DATE_COL] = pd.to_datetime(df_all[DATE_COL], errors='coerce')

df_date = df_all[
    (df_all[DATE_COL] >= START_DATE) &
    (df_all[DATE_COL] <= END_DATE)
].copy()
print(f'📅 2026년 1~5월 해당: {len(df_date):,}건')

# ══════════════════════════════════════════
#  불만족 필터 (답변6 또는 답변7)
# ══════════════════════════════════════════
mask = pd.Series(False, index=df_date.index)
for col in SAT_COLS:
    if col in df_date.columns:
        mask |= df_date[col].str.strip().isin(TARGET)
    else:
        print(f'  ⚠️  컬럼 "{col}" 없음 — 실제 컬럼명을 확인해주세요')

df_result = df_date[mask].copy()
print(f'😞 불만족/매우불만족: {len(df_result):,}건')

if df_result.empty:
    print('\n⚠️  해당 기간에 불만족 데이터가 없습니다.')
    exit()

# ══════════════════════════════════════════
#  불만족 사유 컬럼 확인
#  (주관식 문항1의 답변 → "불만족(보통)을 선택한 사유")
# ══════════════════════════════════════════
# 주관식 답변1 컬럼 자동 탐색
reason_col = None
for c in df_result.columns:
    if '답변1_주관식' in c or c == '답변1.1':
        reason_col = c
        break

if reason_col:
    print(f'✅ 불만족 사유 컬럼: "{reason_col}"')
else:
    # 컬럼 위치로 직접 접근 (AX = 50번째 열, 0-index: 49)
    try:
        reason_col = df_result.columns[49]
        print(f'✅ 불만족 사유 컬럼(위치 기반): "{reason_col}"')
    except IndexError:
        print('⚠️  불만족 사유 컬럼을 찾지 못했습니다. 아래 컬럼 목록을 확인하세요.')
        print(list(df_result.columns))

# ══════════════════════════════════════════
#  월 컬럼 추가 & 월별 저장
# ══════════════════════════════════════════
df_result['월'] = df_result[DATE_COL].dt.month

OUT_DIR = os.path.join(FOLDER, '불만족_월별_로데이터')
os.makedirs(OUT_DIR, exist_ok=True)

print(f'\n💾 저장 폴더: {OUT_DIR}\n')
total = 0
for month in sorted(df_result['월'].unique()):
    group = df_result[df_result['월'] == month].drop(columns=['월'])
    out_path = os.path.join(OUT_DIR, f'2026년{int(month):02d}월_불만족_로데이터.xlsx')
    group.to_excel(out_path, index=False)
    print(f'  📄 2026년 {int(month)}월: {len(group):,}건  →  {os.path.basename(out_path)}')
    total += len(group)

print(f'\n✅ 완료! 총 {total:,}건 추출 → 폴더를 확인하세요.')

# ══════════════════════════════════════════
#  월별 요약 출력
# ══════════════════════════════════════════
print('\n[ 월별 요약 ]')
summary = df_result.groupby('월').apply(
    lambda x: pd.Series({
        '전체건수': len(x),
        '매우불만족': (x[SAT_COLS].isin(['매우불만족']).any(axis=1)).sum(),
        '불만족':    (x[SAT_COLS].isin(['불만족']).any(axis=1) &
                     ~x[SAT_COLS].isin(['매우불만족']).any(axis=1)).sum(),
    })
)
print(summary.to_string())
