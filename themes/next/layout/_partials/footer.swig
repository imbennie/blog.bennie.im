  <div class="copyright" >
    {% set current = date(Date.now(), "YYYY") %}
    &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
    <span itemprop="copyrightYear">{{ current }}</span>
    <span class="with-love">
      <i class="fa fa-{{ theme.authoricon }}"></i>
    </span>
    <span class="author" itemprop="copyrightHolder"><a href="/">{{ config.author }}</a></span>
    <span>{{ __('arr') }}</span>
  </div>


  <div class="hosted">
   <p>Hosted by <a href="https://pages.github.com" style="font-weight: bold">Github Pages</a> </p>
  </div>



<div>

  {% if theme.copyright %}
  <div class="powered-by">
    {{ __('footer.powered', '<a class="theme-link" href="https://hexo.io">Hexo</a>') }}
  </div>

  <div class="theme-info">
    {{ __('footer.theme') }} -
    <a class="theme-link" href="https://github.com/iissnan/hexo-theme-next">
      NexT.{{ theme.scheme }}
    </a>
  </div>
  {% endif %}
</div>
