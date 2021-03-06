# Ian Dennis Miller
# Arctic (R-TeX) data bridge
# write values for reuse in LaTeX

latex_results_init = function(filename) {
  cat('% ', filename, '\n', sep='', file=filename)
}

latex_declare = function(prefix, filename) {
  cat('\\declare{', prefix, '/}\n', sep="", file=filename, append=TRUE)
}

model_str = function(tmp_str) {
  tmp_str = str_replace_all(tmp_str, '\\~', 'R')
  tmp_str = str_replace_all(tmp_str, '\\+', 'P')
  tmp_str = str_replace_all(tmp_str, '\\*', 'M')
  tmp_str = str_replace_all(tmp_str, '\\.', '_')
  tmp_str = str_replace_all(tmp_str, '\\:', ' M ')
  tmp_str = str_replace_all(tmp_str, '\\s+', ' ')
  tmp_str = str_replace_all(tmp_str, '\\(', '')
  tmp_str = str_replace_all(tmp_str, '\\)', '')
  tmp_str = str_replace_all(tmp_str, '  ', ' ')
  return(tmp_str)
}

latex_write_val = function(filename, prefix, key, value) {
  cat('\\setvalue{', prefix, '/', key, ' = ', sprintf("%0.8f", value), '}\n', sep="", file=filename, append=TRUE)
}

latex_lm_write = function(model, fit, filename, name=FALSE) {
  if (name == FALSE) {
    name = model_str(as.character(model))
  }  
  cat('\n% glm: ', as.character(model), '\n', sep="", file=filename, append=TRUE)
  latex_declare(name, filename)

  tmp_lm_results = lm(model, data=fit$data)
  tmp_betas = lm.beta(fit)
  
  latex_write_val(filename=filename, prefix=name, key="df", value=fit$df.residual)
  latex_write_val(filename=filename, prefix=name, key="adjr2", value=summary(tmp_lm_results)$adj.r.squared)
  latex_write_val(filename=filename, prefix=name, key="bic", value=bic(fit))
  
  for (dimension_name in attr(getSummary(fit)$coef, "dimnames")[[1]]) {
    est = getSummary(fit)$coef[[dimension_name,"est"]]
    p = getSummary(fit)$coef[[dimension_name,"p"]]
    stat = getSummary(fit)$coef[[dimension_name,"stat"]]
    
    tmp_prefix = paste0(name, '/', model_str(dimension_name))
    latex_declare(tmp_prefix, filename)    
    latex_write_val(filename=filename, prefix=tmp_prefix, key="estimate", value=est)
    latex_write_val(filename=filename, prefix=tmp_prefix, key="p", value=p)
    latex_write_val(filename=filename, prefix=tmp_prefix, key="t", value=stat)
  }
  
  for (beta_name in names(tmp_betas)) {
    latex_write_val(filename=filename, prefix=name, key=paste0(model_str(beta_name), "/beta"), value=tmp_betas[[beta_name]])
  }
}

latex_sobel_write = function(iv, mv, dv, result, filename, name=FALSE) {
  if (name == FALSE) {
    name = model_str(paste(iv, mv, dv, sep=" L "))
  }

  cat('\n% sobel test suite: independent=', iv, '; mediator=', mv, '; dependent=', dv, '\n', sep="", file=filename, append=TRUE)
  latex_declare(name, filename)
  latex_declare(paste0(name, '/sobel'), filename)
  latex_declare(paste0(name, '/aroian'), filename)
  latex_declare(paste0(name, '/goodman'), filename)

  latex_write_val(filename, name, "sobel/z", result["z.value","Sobel"])
  latex_write_val(filename, name, "sobel/p", result["p.value","Sobel"])
  latex_write_val(filename, name, "aroian/z", result["z.value","Aroian"])
  latex_write_val(filename, name, "aroian/p", result["p.value","Aroian"])
  latex_write_val(filename, name, "goodman/z", result["z.value","Goodman"])
  latex_write_val(filename, name, "goodman/p", result["p.value","Goodman"])
}
