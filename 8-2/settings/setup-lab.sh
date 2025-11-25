#!/bin/bash

echo "=============================================="
echo "DO280 Lab 8-2: 복합 트러블슈팅 환경 구성"
echo "=============================================="
echo ""

# production 프로젝트가 이미 있는지 확인
if oc get project production &>/dev/null; then
    echo "✓ production 프로젝트가 이미 존재합니다."
else
    echo "✗ production 프로젝트가 없습니다. 먼저 8-1 실습을 완료하세요."
    exit 1
fi

# redhat-sa ServiceAccount 확인
if oc get sa redhat-sa -n production &>/dev/null; then
    echo "✓ redhat-sa ServiceAccount가 존재합니다."
else
    echo "✗ redhat-sa ServiceAccount가 없습니다."
    echo "  8-1 실습을 먼저 완료하세요."
    exit 1
fi

# anyuid SCC 부여 확인
if oc get rolebinding system:openshift:scc:anyuid -n production &>/dev/null; then
    echo "✓ anyuid SCC가 redhat-sa에 부여되어 있습니다."
else
    echo "⚠ anyuid SCC가 redhat-sa에 부여되지 않았습니다."
    echo "  8-1 실습을 먼저 완료하세요."
    exit 1
fi

echo ""
echo "📦 문제가 있는 애플리케이션 배포 중..."
echo ""

# 기존 리소스 정리
oc delete deployment team -n production 2>/dev/null || true
oc delete service team -n production 2>/dev/null || true
oc delete route team -n production 2>/dev/null || true
oc delete configmap team-config -n production 2>/dev/null || true

# 대기
sleep 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 문제가 있는 애플리케이션 배포
oc apply -f "${SCRIPT_DIR}/production-broken-app.yaml"

echo ""
echo "⏳ 리소스 배포 대기 중 (5초)..."
sleep 5

echo ""
echo "=============================================="
echo "현재 상태 확인"
echo "=============================================="
echo ""

echo "📋 Deployment 상태:"
oc get deployment team -n production
echo ""

echo "🔍 Pod 상태:"
oc get pods -n production -l app=team
echo ""

echo "🌐 Service 상태:"
oc get service team -n production
echo ""

echo "🚪 Route 상태:"
oc get route team -n production
echo ""

echo "=============================================="
echo "⚠️  문제 상황 설정 완료!"
echo "=============================================="
echo ""
echo "발견할 문제들:"
echo "  1. Pod가 CrashLoopBackOff 상태 (권한 부족)"
echo "  2. Service selector 오류 (app=teams → app=team)"
echo "  3. Service targetPort 오류 (8080 → 80)"
echo ""
echo "다음 단계:"
echo "  cd /home/student/Desktop/DO280_labs/8-2"
echo "  README.md 파일을 참고하여 트러블슈팅을 시작하세요"
echo ""
echo "=============================================="
