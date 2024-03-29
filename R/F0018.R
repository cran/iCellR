#' Run UMAP on PCA Data (Computes a manifold approximation and projection)
#'
#' This function takes an object of class iCellR and runs UMAP on PCA data.
#' @param x An object of class iCellR.
#' @param dims PC dimentions to be used for UMAP analysis.
#' @param my.seed seed number, default = 0.
#' @param n_neighbors The size of local neighborhood (in terms of number of
#'   neighboring sample points) used for manifold approximation. Larger values
#'   result in more global views of the manifold, while smaller values result in
#'   more local data being preserved. In general values should be in the range
#'   \code{2} to \code{100}.
#' @param n_components The dimension of the space to embed into. This defaults
#'   to \code{2} to provide easy visualization, but can reasonably be set to any
#'   integer value in the range \code{2} to \code{100}.
#' @param metric Type of distance metric to use to find nearest neighbors. One
#'   of:
#' \itemize{
#'   \item \code{"euclidean"} (the default)
#'   \item \code{"cosine"}
#'   \item \code{"manhattan"}
#'   \item \code{"hamming"}
#'   \item \code{"categorical"} (see below)
#' }
#' Only applies if \code{nn_method = "annoy"} (for \code{nn_method = "fnn"}, the
#' distance metric is always "euclidean").
#'
#' If \code{X} is a data frame or matrix, then multiple metrics can be
#' specified, by passing a list to this argument, where the name of each item in
#' the list is one of the metric names above. The value of each list item should
#' be a vector giving the names or integer ids of the columns to be included in
#' a calculation, e.g. \code{metric = list(euclidean = 1:4, manhattan = 5:10)}.
#'
#' Each metric calculation results in a separate fuzzy simplicial set, which are
#' intersected together to produce the final set. Metric names can be repeated.
#' Because non-numeric columns are removed from the data frame, it is safer to
#' use column names than integer ids.
#'
#' Factor columns can also be used by specifying the metric name
#' \code{"categorical"}. Factor columns are treated different from numeric
#' columns and although multiple factor columns can be specified in a vector,
#' each factor column specified is processed individually. If you specify
#' a non-factor column, it will be coerced to a factor.
#'
#' For a given data block, you may override the \code{pca} and \code{pca_center}
#' arguments for that block, by providing a list with one unnamed item
#' containing the column names or ids, and then any of the \code{pca} or
#' \code{pca_center} overrides as named items, e.g. \code{metric =
#' list(euclidean = 1:4, manhattan = list(5:10, pca_center = FALSE))}. This
#' exists to allow mixed binary and real-valued data to be included and to have
#' PCA applied to both, but with centering applied only to the real-valued data
#' (it is typical not to apply centering to binary data before PCA is applied).
#' @param n_epochs Number of epochs to use during the optimization of the
#'   embedded coordinates. By default, this value is set to \code{500} for datasets
#'   containing 10,000 vertices or less, and \code{200} otherwise.
#' @param scale Scaling to apply to \code{X} if it is a data frame or matrix:
#' \itemize{
#'   \item{\code{"none"} or \code{FALSE} or \code{NULL}} No scaling.
#'   \item{\code{"Z"} or \code{"scale"} or \code{TRUE}} Scale each column to
#'   zero mean and variance 1.
#'   \item{\code{"maxabs"}} Center each column to mean 0, then divide each
#'   element by the maximum absolute value over the entire matrix.
#'   \item{\code{"range"}} Range scale the entire matrix, so the smallest
#'   element is 0 and the largest is 1.
#'   \item{\code{"colrange"}} Scale each column in the range (0,1).
#' }
#' For UMAP, the default is \code{"none"}.
#' @param learning_rate Initial learning rate used in optimization of the
#'   coordinates.
#' @param init Type of initialization for the coordinates. Options are:
#'   \itemize{
#'     \item \code{"spectral"} Spectral embedding using the normalized Laplacian
#'     of the fuzzy 1-skeleton, with Gaussian noise added.
#'     \item \code{"normlaplacian"}. Spectral embedding using the normalized
#'     Laplacian of the fuzzy 1-skeleton, without noise.
#'     \item \code{"random"}. Coordinates assigned using a uniform random
#'     distribution between -10 and 10.
#'     \item \code{"lvrandom"}. Coordinates assigned using a Gaussian
#'     distribution with standard deviation 1e-4, as used in LargeVis
#'     (Tang et al., 2016) and t-SNE.
#'     \item \code{"laplacian"}. Spectral embedding using the Laplacian Eigenmap
#'     (Belkin and Niyogi, 2002).
#'     \item \code{"pca"}. The first two principal components from PCA of
#'     \code{X} if \code{X} is a data frame, and from a 2-dimensional classical
#'     MDS if \code{X} is of class \code{"dist"}.
#'     \item \code{"spca"}. Like \code{"pca"}, but each dimension is then scaled
#'     so the standard deviation is 1e-4, to give a distribution similar to that
#'     used in t-SNE. This is an alias for \code{init = "pca", init_sdev =
#'     1e-4}.
#'     \item \code{"agspectral"} An "approximate global" modification of
#'     \code{"spectral"} which all edges in the graph to a value of 1, and then
#'     sets a random number of edges (\code{negative_sample_rate} edges per
#'     vertex) to 0.1, to approximate the effect of non-local affinities.
#'     \item A matrix of initial coordinates.
#'   }
#'  For spectral initializations, (\code{"spectral"}, \code{"normlaplacian"},
#'  \code{"laplacian"}), if more than one connected component is identified,
#'  each connected component is initialized separately and the results are
#'  merged. If \code{verbose = TRUE} the number of connected components are
#'  logged to the console. The existence of multiple connected components
#'  implies that a global view of the data cannot be attained with this
#'  initialization. Either a PCA-based initialization or increasing the value of
#'  \code{n_neighbors} may be more appropriate.
#' @param init_sdev If non-\code{NULL}, scales each dimension of the initialized
#'   coordinates (including any user-supplied matrix) to this standard
#'   deviation. By default no scaling is carried out, except when \code{init =
#'   "spca"}, in which case the value is \code{0.0001}. Scaling the input may
#'   help if the unscaled versions result in initial coordinates with large
#'   inter-point distances or outliers. This usually results in small gradients
#'   during optimization and very little progress being made to the layout.
#'   Shrinking the initial embedding by rescaling can help under these
#'   circumstances. Scaling the result of \code{init = "pca"} is usually
#'   recommended and \code{init = "spca"} as an alias for \code{init = "pca",
#'   init_sdev = 1e-4} but for the spectral initializations the scaled versions
#'   usually aren't necessary unless you are using a large value of
#'   \code{n_neighbors} (e.g. \code{n_neighbors = 150} or higher).
#' @param spread The effective scale of embedded points. In combination with
#'   \code{min_dist}, this determines how clustered/clumped the embedded points
#'   are.
#' @param min_dist The effective minimum distance between embedded points.
#'   Smaller values will result in a more clustered/clumped embedding where
#'   nearby points on the manifold are drawn closer together, while larger
#'   values will result on a more even dispersal of points. The value should be
#'   set relative to the \code{spread} value, which determines the scale at
#'   which embedded points will be spread out.
#' @param set_op_mix_ratio Interpolate between (fuzzy) union and intersection as
#'   the set operation used to combine local fuzzy simplicial sets to obtain a
#'   global fuzzy simplicial sets. Both fuzzy set operations use the product
#'   t-norm. The value of this parameter should be between \code{0.0} and
#'   \code{1.0}; a value of \code{1.0} will use a pure fuzzy union, while
#'   \code{0.0} will use a pure fuzzy intersection.
#' @param local_connectivity The local connectivity required -- i.e. the number
#'   of nearest neighbors that should be assumed to be connected at a local
#'   level. The higher this value the more connected the manifold becomes
#'   locally. In practice this should be not more than the local intrinsic
#'   dimension of the manifold.
#' @param bandwidth The effective bandwidth of the kernel if we view the
#'   algorithm as similar to Laplacian Eigenmaps. Larger values induce more
#'   connectivity and a more global view of the data, smaller values concentrate
#'   more locally.
#' @param repulsion_strength Weighting applied to negative samples in low
#'   dimensional embedding optimization. Values higher than one will result in
#'   greater weight being given to negative samples.
#' @param negative_sample_rate The number of negative edge/1-simplex samples to
#'   use per positive edge/1-simplex sample in optimizing the low dimensional
#'   embedding.
#' @param a More specific parameters controlling the embedding. If \code{NULL}
#'   these values are set automatically as determined by \code{min_dist} and
#'   \code{spread}.
#' @param b More specific parameters controlling the embedding. If \code{NULL}
#'   these values are set automatically as determined by \code{min_dist} and
#'   \code{spread}.
#' @param nn_method Method for finding nearest neighbors. Options are:
#'   \itemize{
#'     \item \code{"fnn"}. Use exact nearest neighbors via the
#'       \href{https://cran.r-project.org/package=FNN}{FNN} package.
#'     \item \code{"annoy"} Use approximate nearest neighbors via the
#'       \href{https://cran.r-project.org/package=RcppAnnoy}{RcppAnnoy} package.
#'    }
#'   By default, if \code{X} has less than 4,096 vertices, the exact nearest
#'   neighbors are found. Otherwise, approximate nearest neighbors are used.
#'   You may also pass precalculated nearest neighbor data to this argument. It
#'   must be a list consisting of two elements:
#'   \itemize{
#'     \item \code{"idx"}. A \code{n_vertices x n_neighbors} matrix
#'     containing the integer indexes of the nearest neighbors in \code{X}. Each
#'     vertex is considered to be its own nearest neighbor, i.e.
#'     \code{idx[, 1] == 1:n_vertices}.
#'     \item \code{"dist"}. A \code{n_vertices x n_neighbors} matrix
#'     containing the distances of the nearest neighbors.
#'   }
#'   Multiple nearest neighbor data (e.g. from two different precomputed
#'   metrics) can be passed by passing a list containing the nearest neighbor
#'   data lists as items.
#'   The \code{n_neighbors} parameter is ignored when using precomputed
#'   nearest neighbor data.
#' @param n_trees Number of trees to build when constructing the nearest
#'   neighbor index. The more trees specified, the larger the index, but the
#'   better the results. With \code{search_k}, determines the accuracy of the
#'   Annoy nearest neighbor search. Only used if the \code{nn_method} is
#'   \code{"annoy"}. Sensible values are between \code{10} to \code{100}.
#' @param search_k Number of nodes to search during the neighbor retrieval. The
#'   larger k, the more the accurate results, but the longer the search takes.
#'   With \code{n_trees}, determines the accuracy of the Annoy nearest neighbor
#'   search. Only used if the \code{nn_method} is \code{"annoy"}.
#' @param approx_pow If \code{TRUE}, use an approximation to the power function
#'   in the UMAP gradient, from
#'   \url{https://martin.ankerl.com/2012/01/25/optimized-approximative-pow-in-c-and-cpp/}.
#' @param y Optional target data for supervised dimension reduction. Can be a
#' vector, matrix or data frame. Use the \code{target_metric} parameter to
#' specify the metrics to use, using the same syntax as \code{metric}. Usually
#' either a single numeric or factor column is used, but more complex formats
#' are possible. The following types are allowed:
#'   \itemize{
#'     \item Factor columns with the same length as \code{X}. \code{NA} is
#'     allowed for any observation with an unknown level, in which case
#'     UMAP operates as a form of semi-supervised learning. Each column is
#'     treated separately.
#'     \item Numeric data. \code{NA} is \emph{not} allowed in this case. Use the
#'     parameter \code{target_n_neighbors} to set the number of neighbors used
#'     with \code{y}. If unset, \code{n_neighbors} is used. Unlike factors,
#'     numeric columns are grouped into one block unless \code{target_metric}
#'     specifies otherwise. For example, if you wish columns \code{a} and
#'     \code{b} to be treated separately, specify
#'     \code{target_metric = list(euclidean = "a", euclidean = "b")}. Otherwise,
#'     the data will be effectively treated as a matrix with two columns.
#'     \item Nearest neighbor data, consisting of a list of two matrices,
#'     \code{idx} and \code{dist}. These represent the precalculated nearest
#'     neighbor indices and distances, respectively. This
#'     is the same format as that expected for precalculated data in
#'     \code{nn_method}. This format assumes that the underlying data was a
#'     numeric vector. Any user-supplied value of the \code{target_n_neighbors}
#'     parameter is ignored in this case, because the the number of columns in
#'     the matrices is used for the value. Multiple nearest neighbor data using
#'     different metrics can be supplied by passing a list of these lists.
#'   }
#' Unlike \code{X}, all factor columns included in \code{y} are automatically
#' used.
#' @param target_n_neighbors Number of nearest neighbors to use to construct the
#'   target simplicial set. Default value is \code{n_neighbors}. Applies only if
#'   \code{y} is non-\code{NULL} and \code{numeric}.
#' @param target_metric The metric used to measure distance for \code{y} if
#'   using supervised dimension reduction. Used only if \code{y} is numeric.
#' @param target_weight Weighting factor between data topology and target
#'   topology. A value of 0.0 weights entirely on data, a value of 1.0 weights
#'   entirely on target. The default of 0.5 balances the weighting equally
#'   between data and target. Only applies if \code{y} is non-\code{NULL}.
#' @param pca If set to a positive integer value, reduce data to this number of
#'   columns using PCA. Doesn't applied if the distance \code{metric} is
#'   \code{"hamming"}, or the dimensions of the data is larger than the
#'   number specified (i.e. number of rows and columns must be larger than the
#'   value of this parameter). If you have > 100 columns in a data frame or
#'   matrix, reducing the number of columns in this way may substantially
#'   increase the performance of the nearest neighbor search at the cost of a
#'   potential decrease in accuracy. In many t-SNE applications, a value of 50
#'   is recommended, although there's no guarantee that this is appropriate for
#'   all settings.
#' @param pca_center If \code{TRUE}, center the columns of \code{X} before
#'   carrying out PCA. For binary data, it's recommended to set this to
#'   \code{FALSE}.
#' @param pcg_rand If \code{TRUE}, use the PCG random number generator (O'Neill,
#'   2014) during optimization. Otherwise, use the faster (but probably less
#'   statistically good) Tausworthe "taus88" generator. The default is
#'   \code{TRUE}.
#' @param fast_sgd If \code{TRUE}, then the following combination of parameters
#'   is set: \code{pcg_rand = TRUE}, \code{n_sgd_threads = "auto"} and
#'   \code{approx_pow = TRUE}. The default is \code{FALSE}. Setting this to
#'   \code{TRUE} will speed up the stochastic optimization phase, but give a
#'   potentially less accurate embedding, and which will not be exactly
#'   reproducible even with a fixed seed. For visualization, \code{fast_sgd =
#'   TRUE} will give perfectly good results. For more generic dimensionality
#'   reduction, it's safer to leave \code{fast_sgd = FALSE}. If \code{fast_sgd =
#'   TRUE}, then user-supplied values of \code{pcg_rand}, \code{n_sgd_threads},
#'   and \code{approx_pow} are ignored.
#' @param ret_model If \code{TRUE}, then return extra data that can be used to
#'   add new data to an existing embedding via \code{\link{umap_transform}}. The
#'   embedded coordinates are returned as the list item \code{embedding}. If
#'   \code{FALSE}, just return the coordinates. This parameter can be used in
#'   conjunction with \code{ret_nn}. Note that some settings are incompatible
#'   with the production of a UMAP model: external neighbor data (passed via a
#'   list to \code{nn_method}), and factor columns that were included
#'   via the \code{metric} parameter. In the latter case, the model produced is
#'   based only on the numeric data. A transformation using new data is
#'   possible, but the factor columns in the new data are ignored.
#' @param ret_nn If \code{TRUE}, then in addition to the embedding, also return
#'   nearest neighbor data that can be used as input to \code{nn_method} to
#'   avoid the overhead of repeatedly calculating the nearest neighbors when
#'   manipulating unrelated parameters (e.g. \code{min_dist}, \code{n_epochs},
#'   \code{init}). See the "Value" section for the names of the list items. If
#'   \code{FALSE}, just return the coordinates. Note that the nearest neighbors
#'   could be sensitive to data scaling, so be wary of reusing nearest neighbor
#'   data if modifying the \code{scale} parameter. This parameter can be used in
#'   conjunction with \code{ret_model}.
#' @param n_threads Number of threads to use.
#' @param n_sgd_threads Number of threads to use during stochastic gradient
#'   descent. If set to > 1, then results will not be reproducible, even if
#'   `set.seed` is called with a fixed seed before running. Set to
#'   \code{"auto"} go use the same value as \code{n_threads}.
#' @param grain_size Minimum batch size for multithreading. If the number of
#'   items to process in a thread falls below this number, then no threads will
#'   be used. Used in conjunction with \code{n_threads} and
#'   \code{n_sgd_threads}.
#' @param tmpdir Temporary directory to store nearest neighbor indexes during
#'   nearest neighbor search. Default is \code{\link{tempdir}}. The index is
#'   only written to disk if \code{n_threads > 1} and
#'   \code{nn_method = "annoy"}; otherwise, this parameter is ignored.
#' @param verbose If \code{TRUE}, log details to the console.
#'
#' @return An object of class iCellR.
#' @import uwot
#' @export
run.umap <- function (x = NULL,
                      my.seed = 0,
                      dims = 1:10,
                      n_neighbors = 15,
                      n_components = 2,
                      metric = "euclidean",
                      n_epochs = NULL,
                      learning_rate = 1,
                      scale = FALSE,
                      init = "spectral",
                      init_sdev = NULL,
                      spread = 1,
                      min_dist = 0.01,
                      set_op_mix_ratio = 1,
                      local_connectivity = 1,
                      bandwidth = 1,
                      repulsion_strength = 1,
                      negative_sample_rate = 5,
                      a = NULL,
                      b = NULL,
                      nn_method = NULL,
                      n_trees = 50,
                      search_k = 2 * n_neighbors * n_trees,
                      approx_pow = FALSE,
                      y = NULL,
                      target_n_neighbors = n_neighbors,
                      target_metric = "euclidean",
                      target_weight = 0.5,
                      pca = NULL,
                      pca_center = TRUE,
                      pcg_rand = TRUE,
                      fast_sgd = FALSE,
                      ret_model = FALSE,
                      ret_nn = FALSE,
                      n_threads = 1,
                      n_sgd_threads = 0,
                      grain_size = 1,
                      tmpdir = tempdir(),
                      verbose = getOption("verbose", TRUE)) {
  if ("iCellR" != class(x)[1]) {
    stop("x should be an object of class iCellR")
  }
  # https://github.com/lmcinnes/umap
  # get PCA data
  set.seed(my.seed)
  DATA <- x@pca.data
  DATA <- DATA[dims]
################ uwot
  myUMAP = umap(DATA, n_neighbors = n_neighbors,
                n_components = n_components,
                metric = metric,
                n_epochs = n_epochs,
                learning_rate = learning_rate,
                scale = scale,
                init = init,
                init_sdev = init_sdev,
                spread = spread,
                min_dist = min_dist,
                set_op_mix_ratio = set_op_mix_ratio,
                local_connectivity = local_connectivity,
                bandwidth = bandwidth,
                repulsion_strength = repulsion_strength,
                negative_sample_rate = negative_sample_rate,
                a = a,
                b = b,
                nn_method = nn_method,
                n_trees = n_trees,
                search_k = search_k,
                approx_pow = approx_pow,
                y = y,
                target_n_neighbors = target_n_neighbors,
                target_metric = target_metric,
                target_weight = target_weight,
                pca = pca,
                pca_center = pca_center,
                pcg_rand = pcg_rand,
                fast_sgd = fast_sgd,
                ret_model = ret_model,
                ret_nn = ret_nn,
                n_threads = n_threads,
                n_sgd_threads = n_sgd_threads,
                grain_size = grain_size,
                tmpdir = tmpdir,
                verbose = verbose)
#############
  myUMAP = as.data.frame((myUMAP))
  My.distances = as.data.frame(as.matrix(dist((DATA))))[1]
  colnames(My.distances) <- "V3"
  myUMAP <- cbind(myUMAP,My.distances)
  attributes(x)$umap.data <- myUMAP
# return
  return(x)
}
