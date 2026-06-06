# 코웨이 재무분석 파이썬 실습

코웨이 IR 자료를 활용한 파이썬 데이터 분석 실습 자료입니다.

## 실습 순서

| 파일 | 내용 | 핵심 기술 |
|------|------|----------|
| `01_파일파싱.ipynb` | HTML-XLS 공시 파일 파싱 | BeautifulSoup, 문자열 처리 |
| `02_데이터정제.ipynb` | 단위 통일, 결측값 처리 | pandas 기초 |
| `03_재무지표계산.ipynb` | OPM, CAGR, ARPU, 해외성장률 | pct_change, 사칙연산 |
| `04_시각화.ipynb` | 트렌드, 파이차트, 히트맵 | matplotlib |
| `05_밸류에이션.ipynb` | PER, 적정주가, yfinance | 조건문, 외부 API |
| `06_종합인사이트리포트.ipynb` | 대시보드 + 자동 리포트 | 함수, gridspec |

## 데이터 파일

```
data/
├── coway_annual.csv      # 연간 연결 실적 (2021~2025)
├── coway_quarterly.csv   # 분기별 실적 (2022Q1~2025Q4)
└── coway_overseas.csv    # 해외법인별 실적 (말레이시아/미국/태국)
```

> 실제 공시 파일(xls, pdf)을 파싱하려면 01번 노트북을 먼저 실행하세요.

## 설치 패키지

```bash
pip install pandas matplotlib beautifulsoup4 yfinance
```
