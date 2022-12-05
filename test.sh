TESTES="100 1000 10000"
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo "${GREEN}Single Thread${NC}"

for POP in ${TESTES}; do
  for GEN in ${TESTES}; do
    echo "${BLUE}POP = ${POP}\nGEN = ${GEN}${NC}"
    make run_single ARGS="${GEN} ${POP}" | grep -E "Time|Best solution" | tail -1;
    echo;
  done
done

echo "\n${GREEN}CUDA${NC}"

for POP in ${TESTES}; do
  for GEN in ${TESTES}; do
    echo "${BLUE}POP = ${POP}\nGEN = ${GEN}${NC}"
    make run_cuda ARGS="${GEN} ${POP}" | grep -E "Time|Best solution" | tail -1;
    echo;
  done
done
