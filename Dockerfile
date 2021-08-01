FROM ubuntu:20.04

LABEL description="Bioinformatics Docker Container"
LABEL maintainer="amoustafa@aucegypt.edu"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

##########################################################################################
##########################################################################################

RUN apt-get update --fix-missing && \
apt-get -y upgrade && \
apt-get -y install apt-utils dialog software-properties-common

RUN add-apt-repository universe && \
add-apt-repository multiverse && \
add-apt-repository restricted

##########################################################################################
##########################################################################################

ARG SETUPDIR=/tmp/bioinformatics-toolbox-setup/
RUN mkdir -p $SETUPDIR
WORKDIR $SETUPDIR

##########################################################################################
##########################################################################################

# Prerequisites
###############
###############

RUN apt-get -y install vim nano emacs rsync curl wget screen htop parallel gnupg lsof git locate unrar bc aptitude unzip bison flex \
build-essential libtool autotools-dev automake autoconf cmake \
libboost-dev libboost-all-dev libboost-system-dev libboost-program-options-dev libboost-iostreams-dev libboost-filesystem-dev \
gfortran libgfortran5 \
default-jre default-jdk ant \
python3 python3-dev python3-pip python3-venv \
libssl-dev libcurl4-openssl-dev \
libxml2-dev \
libmagic-dev \
hdf5-* libhdf5-* \
fuse libfuse-dev \
libtbb-dev \
liblzma-dev libbz2-dev \
libbison-dev \
libgmp3-dev \
libncurses5-dev libncursesw5-dev \
liblzma-dev \
caffe-cpu \
cargo \
ffmpeg \
libmagick++-dev \
libavfilter-dev \
dos2unix \
git-lfs

##########################################################################################
##########################################################################################

# Progamming
############
############

# BioPerl
#########
RUN apt-get -y install bioperl

# Biopython
###########
RUN pip3 install --no-cache-dir -U biopython numpy pandas matplotlib scipy seaborn statsmodels plotly bokeh scikit-learn tensorflow keras torch theano jupyterlab

# R
###
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' && \
apt-get update && \
apt-get -y install r-base r-base-dev && \
R -e "install.packages (c('tidyverse', 'tidylog', 'readr', 'dplyr', 'knitr', 'printr', 'rmarkdown', 'shiny', \
'ggplot2', 'gplots', 'plotly', 'rbokeh', 'circlize', 'RColorBrewer', 'formattable', \
'reshape2', 'data.table', 'readxl', 'devtools', 'cowplot', 'tictoc', 'ggpubr', 'patchwork', 'reticulate', \
'rpart', 'rpart.plot', 'randomForest', 'randomForestExplainer', 'randomForestSRC', 'ggRandomForests', 'xgboost', 'gbm', 'iml', \
'gganimate', 'gifski', 'av', 'magick', 'ggvis', 'googleVis', \
'pheatmap', 'Rtsne', 'vsn', 'vegan', 'BiocManager'))" && \
R -e "BiocManager::install(c('DESeq2', 'edgeR', 'dada2', 'phyloseq', 'metagenomeSeq', 'biomaRt'), ask = FALSE, update = TRUE)"

##########################################################################################
##########################################################################################

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

##########################################################################################
##########################################################################################

# Sequence Processing
#####################
#####################

# SeqKit
########
RUN cd $SETUPDIR/ && \
wget -t 0 https://github.com/shenwei356/seqkit/releases/download/v0.16.1/seqkit_linux_amd64.tar.gz && \
tar zxvf seqkit_linux_amd64.tar.gz && \
mv seqkit /usr/local/bin/

# fastp
#######
RUN cd $SETUPDIR/ && \
git clone https://github.com/OpenGene/fastp.git && \
cd $SETUPDIR/fastp && \
make && make install

##########################################################################################
##########################################################################################

# Sequence Search
#################
#################

# BLAST & HMMER
###############
RUN apt-get -y install ncbi-blast+ hmmer

##########################################################################################
##########################################################################################

# Alignment Tools
#################
#################

# MUSCLE
########
RUN cd $SETUPDIR/ && \
wget -t 0 https://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_src.tar.gz && \
tar zxvf muscle3.8.31_src.tar.gz && \
cd $SETUPDIR/muscle3.8.31/src && \
make && mv muscle /usr/local/bin/

# MAFFT
#######
RUN cd $SETUPDIR/ && \
wget -t 0 https://mafft.cbrc.jp/alignment/software/mafft-7.481-with-extensions-src.tgz && \
tar zxvf mafft-7.481-with-extensions-src.tgz && \
cd $SETUPDIR/mafft-7.481-with-extensions/core && \
make clean && make && make install && \
cd $SETUPDIR/mafft-7.481-with-extensions/extensions/ && \
make clean && make && make install


RUN cd $SETUPDIR/ && \
git clone https://github.com/samtools/htslib.git && \
cd $SETUPDIR/htslib && \
autoreconf -i ; git submodule update --init --recursive ; ./configure ; make ; make install

# Samtools
##########
RUN cd $SETUPDIR/ && \
git clone git://github.com/samtools/samtools.git && \
cd $SETUPDIR/samtools && \
autoheader ; autoconf ; ./configure ; make ; make install

# Bcftools
##########
RUN cd $SETUPDIR/ && \
git clone https://github.com/samtools/bcftools.git && \
cd $SETUPDIR/bcftools && \
autoheader ; autoconf ; ./configure ; make ; make install


# Bamtools
##########
RUN cd $SETUPDIR/ && \
git clone git://github.com/pezmaster31/bamtools.git && \
cd $SETUPDIR/bamtools && \
mkdir build && \
cd $SETUPDIR/bamtools/build && \
cmake .. ; make ; make install

# VCFtools
##########
RUN cd $SETUPDIR/ && \
git clone https://github.com/vcftools/vcftools.git && \
cd $SETUPDIR/vcftools && \
./autogen.sh ; ./configure ; make ; make install

# Bedtools
##########
RUN cd $SETUPDIR/ && \
git clone https://github.com/arq5x/bedtools2.git && \
cd $SETUPDIR/bedtools2 && \
make ; make install

##########################################################################################
##########################################################################################

# Phylogenetics
###############
###############

# FastTree
##########
RUN cd $SETUPDIR/ && \
wget -t 0 http://www.microbesonline.org/fasttree/FastTree.c && \
gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm && \
gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm && \
mv FastTree /usr/local/bin && \
mv FastTreeMP /usr/local/bin

##########################################################################################
##########################################################################################

# Finishing
###########
###########
# Removing /usr/local/lib/libgomp.so.1 (seems to be broken) and use /usr/lib/x86_64-linux-gnu/libgomp.so.1 instead
RUN rm -fr /usr/local/lib/libgomp.so.1

RUN cd $SETUPDIR/
RUN echo "#!/usr/bin/bash" > $SETUPDIR/init.sh
RUN echo "export PATH=$PATH:/usr/local/ncbi/sra-tools/bin/:/usr/local/ncbi/ngs-tools/bin/:/usr/local/ncbi/ncbi-vdb/bin:/usr/local/miniconda3/bin:/apps/gatk:/apps/IGV" >> $SETUPDIR/init.sh
RUN echo "source /etc/profile.d/*" >> $SETUPDIR/init.sh
RUN echo "echo '----------------------------------------'" >> $SETUPDIR/init.sh
RUN echo "echo 'Welcome to Bioinformatics Toolbox Light (v1.0)'" >> $SETUPDIR/init.sh
RUN echo "echo '----------------------------------------------'" >> $SETUPDIR/init.sh
RUN echo "echo 'Bioinformatics Toolbox is a docker container for bioinformatics'" >> $SETUPDIR/init.sh
RUN echo "echo " >> $SETUPDIR/init.sh
RUN echo "echo 'For a list of installed tools, please visit: '" >> $SETUPDIR/init.sh
RUN echo "echo 'https://github.com/ahmedmoustafa/bioinformatics-toolbox-light/blob/master/Tools.md'" >> $SETUPDIR/init.sh
RUN echo "echo " >> $SETUPDIR/init.sh
RUN echo "echo 'If you would like to request adding certain tools or report a problem,'" >> $SETUPDIR/init.sh
RUN echo "echo 'please submit an issue https://github.com/ahmedmoustafa/bioinformatics-toolbox-light/issues'" >> $SETUPDIR/init.sh
RUN echo "echo " >> $SETUPDIR/init.sh
RUN echo "echo 'If you use Bioinformatics Toolbox in your work, please cite: '" >> $SETUPDIR/init.sh
RUN echo "echo '10.5281/zenodo.5069735'"  >> $SETUPDIR/init.sh
RUN echo "echo 'Have fun!'" >> $SETUPDIR/init.sh
RUN echo "echo ''" >> $SETUPDIR/init.sh
RUN echo "echo ''" >> $SETUPDIR/init.sh
RUN echo "/usr/bin/bash" >> $SETUPDIR/init.sh
RUN echo "" >> $SETUPDIR/init.sh
RUN mv $SETUPDIR/init.sh /etc/bioinformatics-toolbox.sh
RUN chmod a+x /etc/bioinformatics-toolbox.sh

WORKDIR /root/
ENTRYPOINT ["/etc/bioinformatics-toolbox.sh"]
RUN rm -fr $SETUPDIR

# Versions
##########
RUN python --version ; \
java -version ; \
R --version ; \
blastn -version ; \
muscle -version ; \
mafft --version ; \
samtools  --version ; \
bcftools  --version ; \
bamtools --version ; \
vcftools --version ; \
bedtools --version ; \
seqkit version

##########################################################################################
##########################################################################################
# Coronadb
##########
##########

RUN mkdir /data/ && cd /data/ && git clone https://github.com/ahmedmoustafa/coronadb.git

##########################################################################################
##########################################################################################
